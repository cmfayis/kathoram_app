import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../features/newfeature/screens/staff_call_page.dart';
import '../local_storage/shared_pref.dart';
import 'api_constants.dart';

/// Manages the Socket.IO connection to the backend so the staff app
/// can receive real-time events like INCOMING_CALL and END_CALL.
class SocketService {
  SocketService._();

  static io.Socket? _socket;
  static bool _isConnected = false;

  /// Current active call ID (roomId) — used to end the call screen
  static String? _activeCallId;

  /// Connect to backend socket server after staff logs in.
  static void connect({required String staffId, required String staffName}) {
    if (_isConnected && _socket != null) {
      debugPrint('[SocketService] Already connected, skipping.');
      return;
    }

    final token = MySharedPref.getAuthToken();
    final baseUrl = ApiConstants.baseUrl.endsWith('/')
        ? ApiConstants.baseUrl.substring(0, ApiConstants.baseUrl.length - 1)
        : ApiConstants.baseUrl;

    debugPrint('[SocketService] Connecting to $baseUrl ...');

    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setQuery({'userId': staffId, 'token': token ?? ''})
          .build(),
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      debugPrint('[SocketService] ✅ Connected! socketId=${_socket!.id}');

      // Register this staff's userId so the backend can route events
      _socket!.emit('register', {'userId': staffId});
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      debugPrint('[SocketService] ❌ Disconnected');
    });

    _socket!.onConnectError((error) {
      debugPrint('[SocketService] Connection error: $error');
    });

    _socket!.onError((error) {
      debugPrint('[SocketService] Error: $error');
    });

    // ─── Listen for INCOMING_CALL ───────────────────────────────────
    _socket!.on('INCOMING_CALL', (data) {
      debugPrint('[SocketService] 📞 INCOMING_CALL received: $data');
      _handleIncomingCall(data, staffId, staffName);
    });

    // ─── Listen for END_CALL ────────────────────────────────────────
    _socket!.on('END_CALL', (data) {
      debugPrint('[SocketService] 📴 END_CALL received: $data');
      _handleEndCall(data);
    });

    _socket!.connect();
  }

  /// Disconnect socket (call on logout)
  static void disconnect() {
    debugPrint('[SocketService] Disconnecting...');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    _activeCallId = null;
  }

  /// Whether socket is currently connected
  static bool get isConnected => _isConnected;

  // ═══════════════════════════════════════════════════════════════════
  // PRIVATE HANDLERS
  // ═══════════════════════════════════════════════════════════════════

  static void _handleIncomingCall(
    dynamic data,
    String staffId,
    String staffName,
  ) {
    try {
      final Map<String, dynamic> payload = data is Map<String, dynamic>
          ? data
          : Map<String, dynamic>.from(data);

      // The backend should send roomId (or callId) so we know which
      // Zego room to join. Fallback to call._id if roomId not present.
      final String? roomId =
          payload['roomId']?.toString() ??
          payload['callId']?.toString() ??
          payload['call']?['_id']?.toString();

      final callerData = payload['caller'];
      final String callerName = callerData is Map
          ? (callerData['name']?.toString() ?? 'User')
          : 'User';

      if (roomId == null || roomId.isEmpty) {
        debugPrint(
          '[SocketService] ⚠️ INCOMING_CALL has no roomId/callId! Cannot join Zego room.',
        );
        debugPrint('[SocketService] Payload keys: ${payload.keys.toList()}');
        return;
      }

      debugPrint('[SocketService] Joining Zego room: $roomId as $staffName');
      _activeCallId = roomId;

      // Navigate to the call page
      Get.to(
        () => StaffCallPage(
          callID: roomId,
          staffID: staffId,
          staffName: staffName,
        ),
      );
    } catch (e, stack) {
      debugPrint('[SocketService] Error handling INCOMING_CALL: $e');
      debugPrint('[SocketService] Stack: $stack');
    }
  }

  static void _handleEndCall(dynamic data) {
    try {
      debugPrint('[SocketService] Call ended. Popping call screen...');
      _activeCallId = null;

      // Pop the call screen if we're on it
      if (Get.currentRoute == '/StaffCallPage' || Get.isDialogOpen == false) {
        Get.back();
      }
    } catch (e) {
      debugPrint('[SocketService] Error handling END_CALL: $e');
    }
  }

  /// Emit manual end-call to the backend
  static void emitEndCall({
    required String callId,
    String endedBy = 'receiver',
  }) {
    if (_socket != null && _isConnected) {
      _socket!.emit('END_CALL', {'callId': callId, 'endedBy': endedBy});
      debugPrint('[SocketService] Emitted END_CALL for $callId');
    }
  }
}
