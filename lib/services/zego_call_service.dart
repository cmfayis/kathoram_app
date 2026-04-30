import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

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
    ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
    await ZegoUIKit().initLog();
    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
      [ZegoUIKitSignalingPlugin()],
    );
    log('[ZegoCallService] Initial setup complete (before runApp)');
  }

  /// Call AFTER staff successfully logs in.
  ///
  /// [userID] = unique staff ID from your backend.
  /// This MUST be the same ID the User app uses in ZegoCallUser(staffID, staffName)
  /// when sending the invitation.
  void onUserLogin({
    required String userID,
    required String userName,
  }) {
    if (_isInitialized) {
      log('[ZegoCallService] Already initialized for $userID, skipping.');
      return;
    }

    log('[ZegoCallService] Staff Zego init with userID: $userID');

    ZegoUIKitPrebuiltCallInvitationService().init(
      appID: appID,
      appSign: appSign,
      userID: userID,
      userName: userName,
      plugins: [ZegoUIKitSignalingPlugin()],
      invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
        onError: (error) {
          log('[ZegoCallService] Error: ${error.code} - ${error.message}');
        },
        onIncomingCallReceived: (callID, caller, type, invitees, customData) {
          log('[ZegoCallService] 📞 Incoming call from: ${caller.id} (${caller.name}) | callID: $callID | type: $type');
        },
        onIncomingCallCanceled: (callID, caller, customData) {
          log('[ZegoCallService] ❌ Caller ${caller.name} cancelled the call');
        },
        onIncomingCallTimeout: (callID, caller) {
          log('[ZegoCallService] ⏰ Incoming call timed out (missed call from ${caller.name})');
          // TODO: Call your API to log missed call
        },
        onIncomingCallDeclineButtonPressed: () {
          log('[ZegoCallService] 🚫 Staff declined the call');
          // TODO: Call your API to notify call was declined
        },
        onIncomingCallAcceptButtonPressed: () {
          log('[ZegoCallService] ✅ Staff accepted the call');
          // TODO: Call your API to mark call as accepted/ongoing
        },
      ),
      notificationConfig: ZegoCallInvitationNotificationConfig(
        androidNotificationConfig: ZegoCallAndroidNotificationConfig(
        
          showOnFullScreen: true,
          callChannel: ZegoCallAndroidNotificationChannelConfig(
            channelID: 'ZegoUIKit',
            channelName: 'Call Notifications',
            sound: 'call',
            icon: 'call',
          ),
          missedCallChannel: ZegoCallAndroidNotificationChannelConfig(
            channelID: 'MissedCall',
            channelName: 'Missed Call',
            sound: 'missed_call',
            icon: 'missed_call',
            vibrate: false,
          ),
        ),
        iOSNotificationConfig: ZegoCallIOSNotificationConfig(
          systemCallingIconName: 'CallKitIcon',
        ),
      ),
      requireConfig: (ZegoCallInvitationData data) {
        final config = ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();
        config.topMenuBar.isVisible = true;
        config.topMenuBar.buttons.insert(
          0,
          ZegoCallMenuBarButtonName.minimizingButton,
        );
        return config;
      },
      events: ZegoUIKitPrebuiltCallEvents(
        onCallEnd: (callEndEvent, defaultAction) {
          log('[ZegoCallService] Call ended. Reason: ${callEndEvent.reason}');
          // TODO: Call your "end call" API here
          defaultAction.call();
        },
      ),
    );

    _isInitialized = true;
    log('[ZegoCallService] ✅ Initialization complete. Ready to receive calls.');
  }

  /// Call on logout — disconnects from ZegoCloud signaling.
  Future<void> onUserLogout() async {
    if (!_isInitialized) return;

    log('[ZegoCallService] Uninitializing...');
    await ZegoUIKitPrebuiltCallInvitationService().uninit();
    _isInitialized = false;
    log('[ZegoCallService] Uninitialized.');
  }
}
