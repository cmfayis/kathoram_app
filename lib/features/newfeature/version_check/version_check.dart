import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart' as getx;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../components/custom_widgets/dialog_and_toast/custom_dialogs.dart';
import '../../../services/api_base_model.dart';
import '../../../services/api_constants.dart';
import '../../../services/network_adapter.dart';
import '../../../utils/navigator_key_utils.dart';
import 'app_alert_dialog.dart';
import 'version_controle_model.dart';

/// Checks the remote app version + maintenance flag once per app launch and,
/// if needed, shows a blocking dialog prompting the user to update (or that the
/// app is under maintenance).
///
/// This is the STAFF app, so only the `staff-android` / `staff-ios` entries
/// from the version list are considered.
class VersionControlApi {
  VersionControlApi.init();

  static final VersionControlApi instance = VersionControlApi.init();
  static bool _alreadyChecked = false;

  Future<void> checkVersionStatus() async {
    if (_alreadyChecked) return;
    _alreadyChecked = true;

    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;

      await BaseClient.shared.safeApiCall(
        ApiConstants.currentVersion,
        RequestType.get,
        includeAuth: true,
        onSuccess: (ApiBaseModel response) {
          if (!response.success || response.data is! Map<String, dynamic>) {
            return;
          }

          final data = VersionControlData.fromJson(
            response.data as Map<String, dynamic>,
          );
          if (data.version.isEmpty) return;

          // ================= MAINTENANCE BREAK =================
          // Takes priority over an update prompt — if the backend is down for
          // maintenance we block the app entirely.
          final maintenance = data.version.firstWhereOrNull(
            (e) => e.name == "maintenanceBreak" && e.active == true,
          );
          if (maintenance != null) {
            _showDialog(
              AppUpdateAlertDialog(
                icon: Icons.engineering_outlined,
                title: "Under Maintenance",
                message: maintenance.message?.isNotEmpty == true
                    ? maintenance.message!
                    : "App is under maintenance. Please try again later.",
                // No buttons: nothing for the user to do but wait.
              ),
            );
            return;
          }

          // ================= APP UPDATE =================
          final String platformName = Platform.isIOS
              ? "staff-ios"
              : "staff-android";

          final platformVersion = data.version.firstWhereOrNull(
            (e) => e.name == platformName && e.active == true,
          );
          if (platformVersion == null) return;

          // Only prompt when the store version is actually newer than the
          // installed one.
          if (!_isRemoteNewer(currentVersion, platformVersion.version)) {
            return;
          }

          final bool forceUpdate = platformVersion.forceUpdate;
          final String? redirectUrl = platformVersion.redirectUrl;

          _showDialog(
            AppUpdateAlertDialog(
              onConfirm: () async {
                if (redirectUrl == null || redirectUrl.isEmpty) return;
                await launchUrl(
                  Uri.parse(redirectUrl),
                  mode: LaunchMode.externalApplication,
                );
              },
              // A forced update cannot be dismissed.
              onCancel: forceUpdate ? null : () => getx.Get.back(),
            ),
          );
        },
        // Never let a version check failure interrupt app startup.
        onError: (_) {},
      );
    } catch (_) {
      // silently fail — version checking must never crash the app.
    }
  }

  void _showDialog(Widget child) {
    // Defer until after the current frame so a valid navigator context exists.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (NavigatorKeyHelper.navigatorKey.currentContext == null) return;
      CustomDialogs.showDialogs(child: child);
    });
  }

  /// Returns true when [remote] is a strictly higher semantic version than
  /// [current]. Handles versions of differing segment counts and falls back to
  /// a plain string inequality if either value is non-numeric.
  bool _isRemoteNewer(String current, String? remote) {
    if (remote == null || remote.isEmpty) return false;

    final currentParts = _parseVersion(current);
    final remoteParts = _parseVersion(remote);
    if (currentParts == null || remoteParts == null) {
      return current != remote;
    }

    final length = currentParts.length > remoteParts.length
        ? currentParts.length
        : remoteParts.length;
    for (var i = 0; i < length; i++) {
      final c = i < currentParts.length ? currentParts[i] : 0;
      final r = i < remoteParts.length ? remoteParts[i] : 0;
      if (r > c) return true;
      if (r < c) return false;
    }
    return false;
  }

  List<int>? _parseVersion(String value) {
    // Drop any build/suffix (e.g. "1.0.3+5" or "1.0.3-beta") before comparing.
    final core = value.split(RegExp(r'[+\-]')).first.trim();
    final parts = core.split('.');
    final result = <int>[];
    for (final part in parts) {
      final parsed = int.tryParse(part);
      if (parsed == null) return null;
      result.add(parsed);
    }
    return result.isEmpty ? null : result;
  }
}
