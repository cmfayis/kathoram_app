import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../features/newfeature/screens/staff_call_page.dart';
import '../local_storage/shared_pref.dart';
import 'api_constants.dart';

/// Manages the Socket.IO connection to the backend so the staff app
/// can receive real-time events like INCOMING_CALL and END_CALL.
///
/// Production-grade behavior:
///   1. Built-in socket.io reconnection with exponential backoff + jitter.
///   2. App lifecycle aware (reconnects when the app is foregrounded after
///      the OS silently killed the TCP socket).
///   3. Listens to OS connectivity changes and reconnects immediately on
///      offline → online transitions.
///   4. Exposes [onReconnected] so consumers can resync REST state, because
///      socket.io does not buffer events emitted while we were offline.
///   5. Tracks [_manualDisconnect] so logout does not get auto-undone by
///      the lifecycle/connectivity listeners.
class SocketService extends GetxService with WidgetsBindingObserver {
  /// Lazy singleton accessor — registers with GetX on first use so callers
  /// keep working without touching app bootstrap.
  static SocketService get instance {
    if (!Get.isRegistered<SocketService>()) {
      Get.put<SocketService>(SocketService(), permanent: true);
    }
    return Get.find<SocketService>();
  }

  io.Socket? _socket;

  /// Becomes true after the very first successful connect. Used to tell a
  /// fresh connect apart from a *re*connect inside [onConnect].
  bool _everConnected = false;

  /// True after the user (or logout flow) explicitly calls [disconnect].
  /// While set, lifecycle/connectivity listeners must NOT auto-reconnect.
  bool _manualDisconnect = false;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  String? _staffId;
  String? _staffName;

  /// Fired whenever the socket comes back up after having been connected
  /// at least once before. Consumers should use this to refetch REST state
  /// (lists, profile, queue) since events emitted while offline are LOST.
  VoidCallback? onReconnected;

  bool get isConnected => _socket?.connected ?? false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _connectivitySub = Connectivity()
        .onConnectivityChanged
        .listen(_handleConnectivityChange);
    debugPrint('[SocketService] onInit — observers registered');
  }

  @override
  void onClose() {
    debugPrint('[SocketService] onClose — tearing down');
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySub?.cancel();
    _connectivitySub = null;
    _disposeSocket();
    super.onClose();
  }

  // ═══════════════════════════════════════════════════════════════════
  // LIFECYCLE & CONNECTIVITY
  // ═══════════════════════════════════════════════════════════════════

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('[SocketService] lifecycle → $state '
        '(manual=$_manualDisconnect, connected=$isConnected)');

    if (state == AppLifecycleState.resumed &&
        !_manualDisconnect &&
        !isConnected &&
        _staffId != null) {
      debugPrint('[SocketService] App resumed and socket is down — reconnecting');
      connect(staffId: _staffId!, staffName: _staffName ?? '');
    }
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final hasNetwork =
        results.isNotEmpty && !results.contains(ConnectivityResult.none);
    debugPrint('[SocketService] connectivity → $results (online=$hasNetwork, '
        'manual=$_manualDisconnect, connected=$isConnected)');

    if (hasNetwork &&
        !_manualDisconnect &&
        !isConnected &&
        _staffId != null) {
      debugPrint('[SocketService] Connectivity restored — reconnecting now');
      connect(staffId: _staffId!, staffName: _staffName ?? '');
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // CONNECT / DISCONNECT
  // ═══════════════════════════════════════════════════════════════════

  /// Connect (or reconnect) to the backend socket server.
  ///
  /// Idempotent:
  ///   - already connected      → no-op
  ///   - exists but disconnected → `_socket.connect()` (reuses listeners)
  ///   - null                    → build a fresh socket
  void connect({required String staffId, required String staffName}) {
    _manualDisconnect = false;
    _staffId = staffId;
    _staffName = staffName;

    if (_socket != null && _socket!.connected) {
      debugPrint('[SocketService] connect() — already connected, no-op');
      return;
    }

    if (_socket != null) {
      debugPrint('[SocketService] connect() — reusing existing socket');
      _socket!.connect();
      return;
    }

    final token = MySharedPref.getAuthToken() ?? '';
    final baseUrl = ApiConstants.baseUrl.endsWith('/')
        ? ApiConstants.baseUrl.substring(0, ApiConstants.baseUrl.length - 1)
        : ApiConstants.baseUrl;

    debugPrint('[SocketService] Creating socket → $baseUrl');

    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(0x7FFFFFFF)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setRandomizationFactor(0.5)
          .setTimeout(15000)
          .setAuth({'token': token})
          .setQuery({'userId': staffId, 'token': token})
          .build(),
    );

    _registerSocketListeners();
    _socket!.connect();
  }

  /// Disconnect (called on logout). Marks this as a manual disconnect so
  /// lifecycle/connectivity listeners do not bring it back up.
  void disconnect() {
    debugPrint('[SocketService] disconnect() — manual=true');
    _manualDisconnect = true;
    _everConnected = false;
    _disposeSocket();
    _staffId = null;
    _staffName = null;
  }

  void _disposeSocket() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // SOCKET LISTENERS
  // ═══════════════════════════════════════════════════════════════════

  void _registerSocketListeners() {
    final s = _socket;
    if (s == null) return;

    s.onConnect((_) {
      final wasReconnect = _everConnected;
      _everConnected = true;
      debugPrint('[SocketService] ✅ Connected (id=${s.id}, '
          'reconnect=$wasReconnect)');

      if (_staffId != null) {
        s.emit('register', {'userId': _staffId});
      }

      if (wasReconnect) {
        debugPrint('[SocketService] Firing onReconnected for state resync');
        try {
          onReconnected?.call();
        } catch (e, st) {
          debugPrint('[SocketService] onReconnected threw: $e\n$st');
        }
      }
    });

    s.onDisconnect((reason) {
      debugPrint('[SocketService] ❌ Disconnected (reason=$reason, '
          'manual=$_manualDisconnect)');
    });

    s.onConnectError((err) {
      debugPrint('[SocketService] Connect error: $err');
    });

    s.onError((err) {
      debugPrint('[SocketService] Error: $err');
    });

    s.onReconnectAttempt((attempt) {
      debugPrint('[SocketService] Reconnect attempt #$attempt');
    });

    s.onReconnect((_) {
      debugPrint('[SocketService] Reconnected via socket.io backoff');
    });

    s.onReconnectError((err) {
      debugPrint('[SocketService] Reconnect error: $err');
    });

    s.onReconnectFailed((_) {
      debugPrint('[SocketService] Reconnect failed (all attempts exhausted)');
    });

    s.on('INCOMING_CALL', (data) {
      debugPrint('[SocketService] 📞 INCOMING_CALL: $data');
      _handleIncomingCall(data);
    });

    s.on('END_CALL', (data) {
      debugPrint('[SocketService] 📴 END_CALL: $data');
      _handleEndCall(data);
    });
  }

  // ═══════════════════════════════════════════════════════════════════
  // PRIVATE HANDLERS  (unchanged behavior from original implementation)
  // ═══════════════════════════════════════════════════════════════════

  void _handleIncomingCall(dynamic data) {
    try {
      final Map<String, dynamic> payload = data is Map<String, dynamic>
          ? data
          : Map<String, dynamic>.from(data as Map);

      final String? roomId = payload['roomId']?.toString() ??
          payload['callId']?.toString() ??
          payload['call']?['_id']?.toString();

      final callerData = payload['caller'];
      final String callerName = callerData is Map
          ? (callerData['name']?.toString() ?? 'User')
          : 'User';

      if (roomId == null || roomId.isEmpty) {
        debugPrint(
          '[SocketService] ⚠️ INCOMING_CALL has no roomId/callId! '
          'Cannot join Zego room. Payload keys: ${payload.keys.toList()}',
        );
        return;
      }

      final staffId = _staffId;
      final staffName = _staffName ?? callerName;
      if (staffId == null) {
        debugPrint('[SocketService] ⚠️ INCOMING_CALL but staff is not set');
        return;
      }

      debugPrint('[SocketService] Joining Zego room: $roomId as $staffName');

      Get.to(
        () => StaffCallPage(
          callID: roomId,
          staffID: staffId,
          staffName: staffName,
        ),
      );
    } catch (e, stack) {
      debugPrint('[SocketService] Error handling INCOMING_CALL: $e\n$stack');
    }
  }

  void _handleEndCall(dynamic data) {
    try {
      debugPrint('[SocketService] Call ended. Popping call screen...');

      if (Get.currentRoute == '/StaffCallPage' || Get.isDialogOpen == false) {
        Get.back();
      }
    } catch (e) {
      debugPrint('[SocketService] Error handling END_CALL: $e');
    }
  }

  /// Emit manual end-call to the backend.
  void emitEndCall({
    required String callId,
    String endedBy = 'receiver',
  }) {
    if (_socket?.connected == true) {
      _socket!.emit('END_CALL', {'callId': callId, 'endedBy': endedBy});
      debugPrint('[SocketService] Emitted END_CALL for $callId');
    } else {
      debugPrint('[SocketService] emitEndCall skipped — socket not connected');
    }
  }
}
