import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

// Make sure these imports match your actual project structure
import '../core/app_colors.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to Login after 4 seconds
    Timer(const Duration(seconds: 4), () {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen size for better circle positioning
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: Stack(
        children: [
          // Top Right Concentric Segmented Circles
          Positioned(
            right: -size.width * 0.55,
            top: -size.width * 0.55,
            child: const _SplashScreenCircles(),
          ),
          // Bottom Left Concentric Segmented Circles
          Positioned(
            left: -size.width * 0.55,
            bottom: -size.width * 0.55,
            child: const _SplashScreenCircles(),
          ),
          // Center Logo Area
          Center(
            child: Image.asset('assets/png/AI_Image 1.png'),
          ),
        ],
      ),
    );
  }
}


/// Widget to hold the custom painter for the rings
class _SplashScreenCircles extends StatelessWidget {
  const _SplashScreenCircles({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      // Make it large enough to overflow off the screen nicely
      size: Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.width,
      ),
      painter: _DashedCirclesPainter(),
    );
  }
}

/// Paints dashed/segmented concentric circles
class _DashedCirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap
          .round // Gives the dashed ends a rounded look
      ..strokeWidth = 1.2;

    final center = Offset(size.width / 2, size.height / 2);
    // Use a fixed seed for Random so the dashes look exactly the same on every frame/rebuild
    final random = math.Random(42);

    // Draw 10 concentric circles
    for (int i = 2; i <= 12; i++) {
      double radius = i * 25.0;
      double currentAngle = 0;

      // Draw arcs until we complete a full circle (2 * Pi)
      while (currentAngle < 2 * math.pi) {
        // Randomize the length of the dash and the gap between dashes
        double dashAngle = (random.nextDouble() * 30 + 10) * math.pi / 180;
        double gapAngle = (random.nextDouble() * 15 + 5) * math.pi / 180;

        // Prevent drawing past the full circle
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
