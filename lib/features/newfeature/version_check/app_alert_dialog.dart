import 'package:flutter/material.dart';

import '../../../components/custom_widgets/custom_button.dart';
import '../core/app_colors.dart';

/// Generic blocking dialog used for both the "Update available" prompt and the
/// "App under maintenance" notice.
///
/// - When [onConfirm] is null the confirm (Update) button is hidden — used for
///   the maintenance break where there is nothing for the user to do.
/// - When [onCancel] is null the "Later" button is hidden — used for a forced
///   update so the user cannot dismiss the prompt.
class AppUpdateAlertDialog extends StatelessWidget {
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final IconData icon;
  final String title;
  final String message;
  final String confirmText;

  const AppUpdateAlertDialog({
    super.key,
    this.onConfirm,
    this.onCancel,
    this.icon = Icons.system_update,
    this.title = "Update Available",
    this.message = "Stay up to date! Download the latest version now.",
    this.confirmText = "Update",
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Block back press; the user must act via the buttons (or the prompt is
      // intentionally non-dismissible for a forced update / maintenance).
      canPop: false,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
              child: Icon(icon, size: 44, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF555759),
              ),
              textAlign: TextAlign.center,
            ),
            if (onConfirm != null || onCancel != null) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  if (onCancel != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.primaryBlue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Later",
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  if (onCancel != null && onConfirm != null)
                    const SizedBox(width: 12),
                  if (onConfirm != null)
                    Expanded(
                      child: CustomElevatedButton(
                        onTap: onConfirm,
                        color: AppColors.primaryBlue,
                        height: 48,
                        outlineShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          confirmText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
