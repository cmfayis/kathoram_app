import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../../../services/zego_call_service.dart';

/// Manual call page — used as a fallback when the staff joins via
/// socket event (backend notification). The primary path is the
/// Zego invitation system which auto-shows its own UI.
class StaffCallPage extends StatefulWidget {
  final String callID; // Same callID (roomId) the user app generated
  final String staffID; // This staff's unique ID
  final String staffName;

  const StaffCallPage({
    super.key,
    required this.callID,
    required this.staffID,
    required this.staffName,
  });

  @override
  State<StaffCallPage> createState() => _StaffCallPageState();
}

class _StaffCallPageState extends State<StaffCallPage> {
  @override
  void initState() {
    super.initState();
    debugPrint('[StaffCallPage] Joining room: ${widget.callID} as ${widget.staffName} (${widget.staffID})');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ZegoUIKitPrebuiltCall(
        appID: ZegoCallService.appID,
        appSign: ZegoCallService.appSign,
        callID: widget.callID,
        userID: widget.staffID,
        userName: widget.staffName,
        config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
          ..turnOnCameraWhenJoining = false
          ..turnOnMicrophoneWhenJoining = true
          ..useSpeakerWhenJoining = true,
        events: ZegoUIKitPrebuiltCallEvents(
          onCallEnd: (ZegoCallEndEvent event, VoidCallback defaultAction) {
            debugPrint('[StaffCallPage] Call ended. Reason: ${event.reason}');
            defaultAction.call();
          },
        ),
      ),
    );
  }
}
