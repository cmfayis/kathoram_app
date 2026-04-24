import 'package:flutter/material.dart';
import 'dart:io';

import 'package:get/get.dart';

import 'package:kathoram/features/newfeature/auth/controller/auth_controller.dart';
import '../core/app_colors.dart';
import '../widgets/custom_button.dart';

class UploadProfilePictureScreen extends StatelessWidget {
  const UploadProfilePictureScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const SizedBox(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Upload Profile Picture',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 40),
            Obx(
              () => CustomPaint(
                painter: _DashedRectPainter(
                  color: Colors.grey.shade400,
                  strokeWidth: 1.5,
                  gap: 5.0,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey.shade200.withOpacity(0.5),
                  ),
                  child: Column(
                    children: [
                      authController.selectedProfileImagePath.value == null
                          ? const Icon(
                              Icons.cloud_upload_outlined,
                              size: 80,
                              color: Colors.grey,
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.file(
                                File(
                                  authController
                                      .selectedProfileImagePath
                                      .value!,
                                ),
                                height: 90,
                                width: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.image,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                      const SizedBox(height: 15),
                      Text(
                        authController.selectedProfileImagePath.value == null
                            ? 'Please Upload a Profile Picture'
                            : 'Profile picture selected',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: authController.pickProfileImage,
                        icon: const Icon(
                          Icons.upload_file,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: const Text(
                          'Upload File',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: authController.skipProfileUpload,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const Spacer(),
            Obx(
              () => CustomButton(
                text: authController.isLoading.value
                    ? 'Please wait...'
                    : 'Continue',
                onPressed: authController.isLoading.value
                    ? () {}
                    : authController.uploadProfileImageAndUpdate,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  _DashedRectPainter({
    this.color = Colors.black,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint dashedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double x = size.width;
    double y = size.height;

    Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, x, y),
          const Radius.circular(20),
        ),
      );

    canvas.drawPath(path, dashedPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
