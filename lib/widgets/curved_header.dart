import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class CurvedHeader extends StatelessWidget {
  final double height;
  final bool showBackButton;

  const CurvedHeader({
    Key? key,
    this.height = 300,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ClipPath(
      clipper: _HeaderClipper(),
      child: Container(
        height: height, // Uses the dynamic height passed in
        width: double.infinity,
        // Using your AppColors, or fallback to the hex color
        color: AppColors.primaryBlue, 
        child: Stack(
          children: [
            // Top Left Dashed Rings
            Positioned(
              left: -size.width * 0.50,
              top: -size.width * 0.50,
              child: const _HeaderCircles(),
            ),
            // Bottom Right Dashed Rings
            Positioned(
              right: -size.width * 0.50,
              bottom: -size.width * 0.35,
              child: const _HeaderCircles(),
            ),

            // Center Logo Image
            Align(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/png/Group 36.png',
                height: 60, // Adjust the height to fit your specific PNG
                fit: BoxFit.contain,
              ),
            ),

            // Conditionally show Back Button
            if (showBackButton)
              Positioned(
                top: MediaQuery.of(context).padding.top + 10, // Accounts for status bar
                left: 20,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 16,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Cuts the bottom of the container into a gentle curve
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40); // Start curve a bit higher up
    // Curve to the bottom center, then back up to the right edge
    path.quadraticBezierTo(
      size.width / 2, size.height,
      size.width, size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// Dashed circles for the header background
class _HeaderCircles extends StatelessWidget {
  const _HeaderCircles({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(MediaQuery.of(context).size.width * 0.8,
          MediaQuery.of(context).size.width * 0.8),
      painter: _DashedCirclesPainter(),
    );
  }
}

/// Painter that draws the broken/dashed concentric rings
class _DashedCirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);
    final random = math.Random(42);

    for (int i = 2; i <= 10; i++) {
      double radius = i * 20.0;
      double currentAngle = 0;

      while (currentAngle < 2 * math.pi) {
        double dashAngle = (random.nextDouble() * 30 + 10) * math.pi / 180;
        double gapAngle = (random.nextDouble() * 15 + 5) * math.pi / 180;

        if (currentAngle + dashAngle > 2 * math.pi) {
          dashAngle = 2 * math.pi - currentAngle;
        }

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          currentAngle,
          dashAngle,
          false,
          paint,
        );

        currentAngle += dashAngle + gapAngle;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}