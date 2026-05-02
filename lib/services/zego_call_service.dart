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

  bool _isInitialized = false;

  /// Whether the service is currently initialized
  bool get isInitialized => _isInitialized;

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

    ZegoUIKitPrebuiltCallInvitationService().init(
      appID: appID,
      appSign: appSign,
      userID: userID,
      userName: userName,
      plugins: [ZegoUIKitSignalingPlugin()],

      // ─── Invitation Events (for debugging) ────────────────────────
      invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
        onError: (error) {
          debugPrint('┌── [ZegoCallService] ❗ ERROR ──────────────────');
          debugPrint('│ code: ${error.code}');
          debugPrint('│ message: ${error.message}');
          debugPrint('└────────────────────────────────────────────────');
        },
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

    _isInitialized = true;
    debugPrint('┌──────────────────────────────────────────────────');
    debugPrint('│ [ZegoCallService] ✅ INIT COMPLETE');
    debugPrint('│ Ready to receive calls for userID: $userID');
    debugPrint('└──────────────────────────────────────────────────');
  }

  /// Call on logout — disconnects from ZegoCloud signaling.
  Future<void> onUserLogout() async {
    if (!_isInitialized) return;

    debugPrint('[ZegoCallService] Uninitializing...');
    await ZegoUIKitPrebuiltCallInvitationService().uninit();
    _isInitialized = false;
    debugPrint('[ZegoCallService] Uninitialized.');
  }
}
