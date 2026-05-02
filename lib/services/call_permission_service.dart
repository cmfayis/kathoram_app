import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Result of a permission request batch — used by the online toggle to
/// refuse going online when critical permissions are missing.
class CallPermissionResult {
  final bool microphone;
  final bool notification;
  final bool systemAlertWindow;
  final bool ignoreBatteryOptimizations;

  const CallPermissionResult({
    required this.microphone,
    required this.notification,
    required this.systemAlertWindow,
    required this.ignoreBatteryOptimizations,
  });

  /// Permissions that MUST be granted for incoming calls to work at all.
  /// Battery optimization is recommended but not strictly required, so
  /// it's not part of this gate.
  bool get hasAllCritical => microphone && notification && systemAlertWindow;

  List<String> get missingCritical => [
        if (!microphone) 'Microphone',
        if (!notification) 'Notifications',
        if (!systemAlertWindow) 'Display over other apps',
      ];
}

/// Requests every runtime permission Zego needs to deliver incoming calls
/// reliably on Android. Called when the staff toggles themselves online —
/// without these grants the call flow is broken, so we gate the toggle.
class CallPermissionService {
  CallPermissionService._();

  static Future<CallPermissionResult> requestAll() async {
    if (!Platform.isAndroid) {
      return const CallPermissionResult(
        microphone: true,
        notification: true,
        systemAlertWindow: true,
        ignoreBatteryOptimizations: true,
      );
    }

    debugPrint('[CallPermissionService] Requesting call permissions...');

    final results = await [
      Permission.microphone,
      Permission.notification,
      Permission.systemAlertWindow,
      Permission.ignoreBatteryOptimizations,
      Permission.scheduleExactAlarm,
    ].request();

    results.forEach((permission, status) {
      debugPrint('[CallPermissionService] $permission → $status');
    });

    return CallPermissionResult(
      microphone:
          results[Permission.microphone]?.isGranted ?? false,
      notification:
          results[Permission.notification]?.isGranted ?? false,
      systemAlertWindow:
          results[Permission.systemAlertWindow]?.isGranted ?? false,
      ignoreBatteryOptimizations:
          results[Permission.ignoreBatteryOptimizations]?.isGranted ?? false,
    );
  }
}
