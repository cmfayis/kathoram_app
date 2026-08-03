import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

/// Plays the device's system ringtone when an incoming call arrives.
///
/// Why we do this manually instead of letting Zego do it:
///   - With `useSystemCallingUI` enabled, the SDK normally relies on the
///     OS notification channel sound. Android *suppresses* channel sounds
///     for the currently-foreground app, so the popup is silent.
///   - Zego does have a `ringtoneConfig` parameter that uses an asset via
///     `audioplayers`, but that path collides with the SDK's own use of
///     `AudioCache.instance.prefix`: the SDK mutates the global prefix
///     when it tries to play, and any later `AssetSource` call fails to
///     resolve because the prefix doesn't match `assets/`. Hence the
///     "Unable to load asset" errors visible in the logs.
///   - `flutter_ringtone_player` plays the device's built-in ringtone
///     directly via the platform's RingtoneManager / AVAudioPlayer — no
///     assets, no AudioCache, no path resolution. It just works.
class _ForegroundRinger {
  static bool _isPlaying = false;

  static Future<void> start() async {
    if (_isPlaying) return;

    // Only ring manually when the app is in the foreground. In
    // background / killed state the OS notification channel plays the
    // custom `zego_incoming.mp3` from res/raw/ — playing this on top
    // would result in two simultaneous ringtones.
    //
    // Foreground states are `resumed` (app fully visible) and `inactive`
    // (app visible but unfocused — which is exactly what happens when
    // Zego's CallKit overlay draws on top of our app).
    final state = WidgetsBinding.instance.lifecycleState;
    final isForeground =
        state == AppLifecycleState.resumed ||
        state == AppLifecycleState.inactive;
    if (!isForeground) {
      debugPrint(
        '[ZegoCallService] Skipping manual ringer (lifecycle: $state) — '
        'OS channel sound will ring',
      );
      return;
    }

    _isPlaying = true;
    try {
      await FlutterRingtonePlayer().play(
        android: AndroidSounds.ringtone,
        ios: IosSounds.electronic,
        looping: true,
        volume: 1.0,
        asAlarm: false,
      );
      debugPrint('[ZegoCallService] 🔔 System ringtone started');
    } catch (e, st) {
      _isPlaying = false;
      debugPrint('[ZegoCallService] ❗ Ringtone failed: $e\n$st');
    }
  }

  static Future<void> stop() async {
    if (!_isPlaying) return;
    _isPlaying = false;
    try {
      await FlutterRingtonePlayer().stop();
      debugPrint('[ZegoCallService] 🔕 Ringtone stopped');
    } catch (_) {}
  }
}

/// Why a Zego signaling login failed — decides whether a retry is worth it.
enum ZegoLoginFailureKind {
  /// ZegoCloud account / app-config level: MAU or DAU quota exhausted,
  /// invalid AppID, or an operation the current plan doesn't include.
  ///
  /// Nothing the client can do fixes this, so retrying just re-hits the same
  /// wall and spams the login API. We stop, and flag the service as degraded.
  accountLimit,

  /// Transient: network drop, connection interrupted, login timeout with no
  /// explicit account-limit message. Safe to retry with backoff.
  retryable,
}

/// Forwards app lifecycle changes into [ZegoCallService] so the retry budget
/// can be reset when the user brings the app back to the foreground.
class _ZegoLifecycleObserver extends WidgetsBindingObserver {
  _ZegoLifecycleObserver(this.onResumed);

  final VoidCallback onResumed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) onResumed();
  }
}

/// Production-ready Zego Cloud call invitation service for the Staff app.
///
/// The Staff app only RECEIVES audio call invitations from the User app.
/// Both apps share the same Zego AppID/AppSign and resourceID "zego_audio_call".
class ZegoCallService {
  ZegoCallService._();
  static final ZegoCallService instance = ZegoCallService._();

  // ============================================================
  // ZegoCloud credentials — MUST match the User app's credentials
  // ============================================================
  static const int appID = 1989024957;
  static const String appSign =
      'e6d8e11e47a3d184fefe93bf57948f147bd6a4d36c3e41e1ecf60b59682a0d4d';

  // ============================================================
  // Error classification
  // ============================================================

  /// ZIM error codes that are account- or app-config-level. Every one of
  /// these fails identically on every retry, so they must never be retried.
  ///
  /// Values mirror `ZIMErrorCode` in the `zego_zim` package — the invitation
  /// `onError` callback forwards the raw signaling (ZIM) code unchanged.
  static const Set<int> _accountLevelErrorCodes = {
    6000003, // invalid AppID
    6000013, // request unsupported by the current ZegoCloud package/plan
    6000015, // exceeded the AppID's daily-active-user (DAU) limit
    6000016, // exceeded the AppID's monthly-active-user (MAU) limit
    6000103, // token invalid — mis-configured credentials
  };

  /// Lowercase substrings that identify an account-level failure when the
  /// numeric code is unknown or generic (the SDK sometimes surfaces the quota
  /// breach only in the message body, e.g. "exceed user mau limit").
  static const List<String> _accountLevelErrorPhrases = [
    'exceed user mau limit',
    'exceed mau limit',
    'mau limit',
    'exceed user dau limit',
    'exceed dau limit',
    'dau limit',
    'monthly active user',
    'daily active user',
    'invalid appid',
    'appid is not exist',
    'package does not support',
  ];

  // ============================================================
  // Reconnect policy
  // ============================================================

  static const Duration _initialRetryDelay = Duration(seconds: 2);
  static const Duration _maxRetryDelay = Duration(seconds: 60);

  /// Consecutive failures tolerated before we give up for this session.
  /// Reset on a successful connection or when the app is next resumed.
  static const int _maxConsecutiveRetries = 5;

  bool _isInitialized = false;

  /// Credentials of the currently logged-in staff, kept so a reconnect can
  /// re-run `init()` without going back through AuthController.
  String? _userID;
  String? _userName;

  int _consecutiveRetries = 0;
  Timer? _retryTimer;
  bool _reconnectInFlight = false;
  StreamSubscription<ZegoSignalingPluginConnectionStateChangedEvent>?
  _connectionSub;
  _ZegoLifecycleObserver? _lifecycleObserver;

  final ValueNotifier<bool> _serviceDegraded = ValueNotifier<bool>(false);
  ZegoUIKitError? _lastAccountError;

  /// Whether the service is currently initialized
  bool get isInitialized => _isInitialized;

  /// True once an ACCOUNT_LIMIT_ERROR has been seen — calls will not work
  /// until the ZegoCloud plan is fixed, and no retry will help.
  ///
  /// Listenable so an internal "service degraded" banner can be driven off it
  /// (via `ValueListenableBuilder`) for admin/ops builds.
  ValueListenable<bool> get isServiceDegraded => _serviceDegraded;

  /// Raw message of the last account-level error, for the banner / ops screen.
  String? get lastAccountErrorMessage => _lastAccountError == null
      ? null
      : '[${_lastAccountError!.code}] ${_lastAccountError!.message}';

  /// True when we burned through the retry budget and are waiting for the app
  /// to be foregrounded again before trying any further reconnects.
  bool get isRetryBudgetExhausted =>
      _consecutiveRetries >= _maxConsecutiveRetries;

  /// Classifies a signaling error into retryable vs. permanently broken.
  ZegoLoginFailureKind _classify(ZegoUIKitError error) {
    if (_accountLevelErrorCodes.contains(error.code)) {
      return ZegoLoginFailureKind.accountLimit;
    }

    final message = error.message.toLowerCase();
    final matchesPhrase = _accountLevelErrorPhrases.any(message.contains);

    return matchesPhrase
        ? ZegoLoginFailureKind.accountLimit
        : ZegoLoginFailureKind.retryable;
  }

  /// MUST be called BEFORE runApp().
  ///
  /// Enables system-level calling UI so that incoming call notifications
  /// appear as native call screens even when the app is killed or in background.
  Future<void> initialSetUp(GlobalKey<NavigatorState> navigatorKey) async {
    debugPrint('┌──────────────────────────────────────────────────');
    debugPrint('│ [ZegoCallService] initialSetUp() START');
    debugPrint('└──────────────────────────────────────────────────');

    ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

    await ZegoUIKit().initLog().then((_) {
      debugPrint('[ZegoCallService] ✅ ZegoUIKit log initialized');
    });

    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI([
      ZegoUIKitSignalingPlugin(),
    ]);

    debugPrint('[ZegoCallService] ✅ useSystemCallingUI configured');
    debugPrint('[ZegoCallService] Initial setup complete (before runApp)');
  }

  /// Call AFTER staff successfully logs in.
  ///
  /// [userID] = unique staff ID from your backend.
  /// This MUST be the same ID the User app uses in ZegoCallUser(staffID, staffName)
  /// when sending the invitation.
  void onUserLogin({required String userID, required String userName}) {
    if (_isInitialized) {
      debugPrint(
        '[ZegoCallService] Already initialized for $userID, skipping.',
      );
      return;
    }

    debugPrint('┌──────────────────────────────────────────────────');
    debugPrint('│ [ZegoCallService] onUserLogin() START');
    debugPrint('│ userID: $userID');
    debugPrint('│ userName: $userName');
    debugPrint('│ appID: $appID');
    debugPrint('└──────────────────────────────────────────────────');

    _userID = userID;
    _userName = userName;
    _consecutiveRetries = 0;
    _isInitialized = true;

    _registerLifecycleObserver();
    _initInvitationService();

    debugPrint('┌──────────────────────────────────────────────────');
    debugPrint('│ [ZegoCallService] ✅ INIT COMPLETE');
    debugPrint('│ Ready to receive calls for userID: $userID');
    debugPrint('└──────────────────────────────────────────────────');
  }

  /// Runs (or re-runs, on reconnect) the prebuilt invitation service init.
  ///
  /// Split out of [onUserLogin] so [_reconnect] can replay it verbatim with
  /// the credentials cached in [_userID] / [_userName].
  Future<void> _initInvitationService() async {
    final userID = _userID;
    final userName = _userName;
    if (userID == null || userName == null) {
      debugPrint('[ZegoCallService] _initInvitationService: no cached user');
      return;
    }

    await ZegoUIKitPrebuiltCallInvitationService().init(
      appID: appID,
      appSign: appSign,
      userID: userID,
      userName: userName,
      plugins: [ZegoUIKitSignalingPlugin()],

      // ─── Invitation Events ────────────────────────────────────────
      invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
        onError: _onInvitationError,
        onIncomingCallReceived: (callID, caller, type, invitees, customData) {
          debugPrint('┌── [ZegoCallService] 📞 INCOMING CALL ──────────');
          debugPrint('│ callID: $callID');
          debugPrint('│ caller: ${caller.id} (${caller.name})');
          debugPrint('│ type: $type');
          debugPrint('│ invitees: ${invitees.map((e) => e.id).toList()}');
          debugPrint('│ customData: $customData');
          debugPrint('└────────────────────────────────────────────────');
          _ForegroundRinger.start();
        },
        onIncomingCallCanceled: (callID, caller, customData) {
          debugPrint(
            '[ZegoCallService] ❌ Call canceled by ${caller.name} | callID: $callID',
          );
          _ForegroundRinger.stop();
        },
        onIncomingCallTimeout: (callID, caller) {
          debugPrint(
            '[ZegoCallService] ⏰ Call timed out from ${caller.name} | callID: $callID',
          );
          _ForegroundRinger.stop();
        },
        onIncomingCallDeclineButtonPressed: () {
          debugPrint('[ZegoCallService] 🚫 Staff DECLINED the call');
          _ForegroundRinger.stop();
        },
        onIncomingCallAcceptButtonPressed: () {
          debugPrint('[ZegoCallService] ✅ Staff ACCEPTED the call');
          _ForegroundRinger.stop();
        },
        onOutgoingCallRejectedCauseBusy: (callID, callee, customData) {
          debugPrint('[ZegoCallService] 📵 Callee busy | callID: $callID');
        },
        onOutgoingCallDeclined: (callID, callee, customData) {
          debugPrint('[ZegoCallService] 📵 Call declined | callID: $callID');
        },
      ),

      // ─── Notification config ──────────────────────────────────────────
      // The `sound` value MUST match a file in android/app/src/main/res/raw/
      // (without extension). The same name MUST be set as "FCM Sound" in the
      // ZegoCloud console for resource `zego_audio_call`, AND the channelID
      // MUST match the console's "FCM Channel ID".
      //
      // Channel IDs are bumped to V2 because Android caches channel settings
      // permanently — the previous channel was created without sound, so a
      // new ID is required to register a channel that actually rings.
      notificationConfig: ZegoCallInvitationNotificationConfig(
        androidNotificationConfig: ZegoCallAndroidNotificationConfig(
          showOnFullScreen: true,
          showOnLockedScreen: true,
          callChannel: ZegoCallAndroidNotificationChannelConfig(
            channelID: 'ZegoCallChannelV2',
            channelName: 'Incoming Calls',
            sound: 'zego_incoming',
            vibrate: true,
          ),
          missedCallChannel: ZegoCallAndroidNotificationChannelConfig(
            channelID: 'ZegoMissedCallChannelV2',
            channelName: 'Missed Calls',
            vibrate: true,
          ),
        ),
        iOSNotificationConfig: ZegoCallIOSNotificationConfig(
          systemCallingIconName: 'CallKitIcon',
        ),
      ),

      // ─── In-app (online / foreground) ringtone ──────────────────────
      // Used when the SDK plays the ringtone from Flutter assets directly
      // (e.g. when a call invitation arrives while the app is already in
      // the foreground). Files must exist in pubspec.yaml assets.
      ringtoneConfig: ZegoCallRingtoneConfig(
        incomingCallPath: 'assets/ringtone/zego_incoming.mp3',
        outgoingCallPath: 'assets/ringtone/zego_outgoing.mp3',
      ),

      // ─── Call UI config ──────────────────────────────────────────────
      requireConfig: (ZegoCallInvitationData data) {
        debugPrint(
          '[ZegoCallService] requireConfig called | type: ${data.type} | inviter: ${data.inviter?.id}',
        );
        final config = ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();
        config.topMenuBar.isVisible = true;
        config.topMenuBar.buttons.insert(
          0,
          ZegoCallMenuBarButtonName.minimizingButton,
        );
        // config.turnOnCameraWhenJoining = false;
        // config.useSpeakerWhenJoining = true;

        // ❌ Remove video view UI
        config.layout = ZegoLayout.pictureInPicture(
          isSmallViewDraggable: false,
          smallViewSize: Size.zero, // 🔥 THIS removes the small preview
        );

        return config;
      },

      // ─── Call lifecycle events ─────────────────────────────────────
      events: ZegoUIKitPrebuiltCallEvents(
        onCallEnd: (callEndEvent, defaultAction) {
          debugPrint(
            '[ZegoCallService] 📴 Call ended. Reason: ${callEndEvent.reason}',
          );
          _ForegroundRinger.stop();
          defaultAction.call();
        },
      ),
    );

    _attachConnectionStateListener();
  }

  // ============================================================
  // Error handling
  // ============================================================

  /// Single entry point for every invitation-layer error.
  ///
  /// Classifies the error, reports it to Crashlytics as a non-fatal, and only
  /// arms a reconnect for the categories where a retry can actually succeed.
  void _onInvitationError(ZegoUIKitError error) {
    final kind = _classify(error);

    switch (kind) {
      case ZegoLoginFailureKind.accountLimit:
        _lastAccountError = error;
        _serviceDegraded.value = true;

        // Cancel anything already armed — the account is the problem now,
        // and a pending retry would only add noise to the login API.
        _cancelPendingRetry();

        debugPrint('┌── [ZegoCallService] ⛔ ACCOUNT_LIMIT_ERROR ─────');
        debugPrint('│ code: ${error.code}');
        debugPrint('│ message: ${error.message}');
        debugPrint('│ method: ${error.method}');
        debugPrint('│ NOT retrying — this is a ZegoCloud account/plan issue');
        debugPrint('│ (MAU/DAU quota or app config). Fix it in the console.');
        debugPrint('└────────────────────────────────────────────────');
        break;

      case ZegoLoginFailureKind.retryable:
        debugPrint('┌── [ZegoCallService] ❗ RETRYABLE ERROR ─────────');
        debugPrint('│ code: ${error.code}');
        debugPrint('│ message: ${error.message}');
        debugPrint('│ method: ${error.method}');
        debugPrint('└────────────────────────────────────────────────');

        _scheduleReconnect(reason: 'error ${error.code}');
        break;
    }

    // Fire-and-forget: Crashlytics reporting must never block or throw into
    // the SDK's callback.
    unawaited(_recordLoginFailure(error, kind));
  }

  /// Records a non-fatal in Crashlytics with the raw Zego error attached as
  /// custom keys, so MAU-limit failures can be told apart from genuine
  /// network failures without pulling device logs.
  Future<void> _recordLoginFailure(
    ZegoUIKitError error,
    ZegoLoginFailureKind kind,
  ) async {
    try {
      final crashlytics = FirebaseCrashlytics.instance;
      await crashlytics.setCustomKey('zego_error_code', error.code);
      await crashlytics.setCustomKey('zego_error_message', error.message);
      await crashlytics.setCustomKey('zego_error_method', error.method);
      await crashlytics.setCustomKey('zego_failure_kind', kind.name);
      await crashlytics.setCustomKey('zego_user_id', _userID ?? 'unknown');
      await crashlytics.setCustomKey('zego_retry_count', _consecutiveRetries);

      await crashlytics.recordError(
        'ZegoCallService login failure [${kind.name}] '
        'code=${error.code} method=${error.method}: ${error.message}',
        StackTrace.current,
        reason: 'zego_invitation_error',
        fatal: false,
      );
    } catch (e) {
      // Crashlytics itself failing is not worth escalating.
      debugPrint('[ZegoCallService] Crashlytics report failed: $e');
    }
  }

  // ============================================================
  // Connection state / reconnect
  // ============================================================

  /// Watches signaling connection state so a drop that never surfaces through
  /// `onError` (silent interruption, login timeout) still triggers a retry.
  void _attachConnectionStateListener() {
    _connectionSub?.cancel();
    try {
      _connectionSub = ZegoUIKit()
          .getSignalingPlugin()
          .getConnectionStateStream()
          .listen(_onConnectionStateChanged);
      debugPrint('[ZegoCallService] 👂 Connection-state listener attached');
    } catch (e) {
      // getConnectionStateStream() dereferences the signaling plugin, which
      // is absent if plugin installation failed. Nothing to listen to.
      debugPrint('[ZegoCallService] Connection-state listener failed: $e');
    }
  }

  void _onConnectionStateChanged(
    ZegoSignalingPluginConnectionStateChangedEvent event,
  ) {
    debugPrint(
      '[ZegoCallService] 🔌 Connection state: ${event.state.name} '
      '(action: ${event.action.name})',
    );

    switch (event.state) {
      case ZegoSignalingPluginConnectionState.connected:
        // Healthy again — clear the backoff so a future outage starts from 2s.
        if (_consecutiveRetries > 0) {
          debugPrint('[ZegoCallService] ✅ Reconnected — retry budget reset');
        }
        _cancelPendingRetry();
        _consecutiveRetries = 0;
        break;

      case ZegoSignalingPluginConnectionState.connecting:
      case ZegoSignalingPluginConnectionState.reconnecting:
        // The SDK is already working on it; adding our own attempt on top
        // would double up the login calls.
        break;

      case ZegoSignalingPluginConnectionState.disconnected:
        _onDisconnected(event.action);
        break;
    }
  }

  void _onDisconnected(ZegoSignalingPluginConnectionAction action) {
    if (_serviceDegraded.value) {
      debugPrint(
        '[ZegoCallService] Disconnected, but account is limited — no retry',
      );
      return;
    }

    switch (action) {
      // Deliberate / terminal disconnects. Retrying either fights the user's
      // own action or loops against a server-side decision.
      case ZegoSignalingPluginConnectionAction.kickedOut:
      case ZegoSignalingPluginConnectionAction.unregistered:
      case ZegoSignalingPluginConnectionAction.success:
        debugPrint(
          '[ZegoCallService] Disconnect (${action.name}) is terminal — '
          'no automatic retry',
        );
        break;

      // Transient: network dropped, or the login handshake timed out without
      // an account-limit message alongside it.
      case ZegoSignalingPluginConnectionAction.interrupted:
      case ZegoSignalingPluginConnectionAction.loginTimeout:
      case ZegoSignalingPluginConnectionAction.tokenExpired:
      case ZegoSignalingPluginConnectionAction.activeLogin:
      case ZegoSignalingPluginConnectionAction.unknown:
        _scheduleReconnect(reason: 'disconnected (${action.name})');
        break;
    }
  }

  /// Arms a single backoff-delayed reconnect.
  ///
  /// Guards against a tight loop three ways: an account-limit short-circuit,
  /// a per-session attempt cap, and a single-flight timer so overlapping
  /// error/state events can't stack up multiple pending attempts.
  void _scheduleReconnect({required String reason}) {
    if (!_isInitialized) return;

    if (_serviceDegraded.value) {
      debugPrint('[ZegoCallService] Skipping reconnect — account limited');
      return;
    }

    if (_retryTimer != null || _reconnectInFlight) {
      debugPrint('[ZegoCallService] Reconnect already pending — ignoring');
      return;
    }

    if (_consecutiveRetries >= _maxConsecutiveRetries) {
      debugPrint(
        '[ZegoCallService] ⏹ Retry budget exhausted '
        '($_maxConsecutiveRetries consecutive failures) — waiting for the '
        'app to be resumed before trying again',
      );
      return;
    }

    // 2s, 4s, 8s, 16s, 32s … capped at 60s.
    final backoffMs =
        _initialRetryDelay.inMilliseconds * (1 << _consecutiveRetries);
    final delay = Duration(
      milliseconds: backoffMs.clamp(
        _initialRetryDelay.inMilliseconds,
        _maxRetryDelay.inMilliseconds,
      ),
    );

    _consecutiveRetries++;
    debugPrint(
      '[ZegoCallService] ⏳ Reconnect #$_consecutiveRetries in '
      '${delay.inSeconds}s ($reason)',
    );

    _retryTimer = Timer(delay, () {
      _retryTimer = null;
      unawaited(_reconnect());
    });
  }

  Future<void> _reconnect() async {
    if (!_isInitialized || _serviceDegraded.value) return;

    _reconnectInFlight = true;
    debugPrint(
      '[ZegoCallService] 🔄 Reconnecting (attempt $_consecutiveRetries)',
    );
    try {
      await ZegoUIKitPrebuiltCallInvitationService().uninit();
      await _initInvitationService();
    } catch (e, st) {
      debugPrint('[ZegoCallService] ❗ Reconnect threw: $e\n$st');
      unawaited(
        _recordLoginFailure(
          ZegoUIKitError(code: -1, message: '$e', method: 'reconnect'),
          ZegoLoginFailureKind.retryable,
        ),
      );
    } finally {
      _reconnectInFlight = false;
    }

    // Success is confirmed by the connection-state listener firing
    // `connected`, which is what actually resets `_consecutiveRetries`.
  }

  void _cancelPendingRetry() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  // ============================================================
  // App lifecycle
  // ============================================================

  void _registerLifecycleObserver() {
    if (_lifecycleObserver != null) return;

    _lifecycleObserver = _ZegoLifecycleObserver(_onAppResumed);
    WidgetsBinding.instance.addObserver(_lifecycleObserver!);
  }

  /// Foregrounding the app is the signal to give the connection another
  /// chance: the retry budget resets and, if we're still down, one attempt
  /// is armed immediately.
  void _onAppResumed() {
    if (!_isInitialized || _serviceDegraded.value) return;

    if (_consecutiveRetries == 0) return;

    debugPrint(
      '[ZegoCallService] ▶ App resumed — resetting retry budget '
      '(was $_consecutiveRetries)',
    );
    _consecutiveRetries = 0;

    ZegoSignalingPluginConnectionState? state;
    try {
      state = ZegoUIKit().getSignalingPlugin().getConnectionState();
    } catch (_) {
      // Plugin not installed — nothing to reconnect to.
      return;
    }

    if (state == ZegoSignalingPluginConnectionState.disconnected) {
      _scheduleReconnect(reason: 'app resumed while disconnected');
    }
  }

  /// Call on logout — disconnects from ZegoCloud signaling.
  Future<void> onUserLogout() async {
    if (!_isInitialized) return;

    debugPrint('[ZegoCallService] Uninitializing...');

    _cancelPendingRetry();
    await _connectionSub?.cancel();
    _connectionSub = null;

    if (_lifecycleObserver != null) {
      WidgetsBinding.instance.removeObserver(_lifecycleObserver!);
      _lifecycleObserver = null;
    }

    _consecutiveRetries = 0;
    _userID = null;
    _userName = null;
    _serviceDegraded.value = false;
    _lastAccountError = null;

    await ZegoUIKitPrebuiltCallInvitationService().uninit();
    _isInitialized = false;
    debugPrint('[ZegoCallService] Uninitialized.');
  }
}
