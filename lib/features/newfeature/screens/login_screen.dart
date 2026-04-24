import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kathoram/features/newfeature/auth/controller/auth_controller.dart';
import 'package:kathoram/routes/route_path.dart';

// Assuming you have these in your project
import '../core/app_colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      // Use LayoutBuilder to push the Sign In button to the bottom
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // 1. Custom Header with Curves, Logo, and Rings
                    const _LoginHeader(),

                    // 2. Form Body
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          const Text(
                            'Login',
                            style: TextStyle(
                              color: AppColors
                                  .primaryBlue, // Assuming this is the bright blue
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 35),

                          // Custom Pill-Shaped Text Fields
                          _PillTextField(
                            label: 'Email',
                            hint: 'Johndoe@example.com',
                            controller: authController.loginEmailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 25),
                          _PillTextField(
                            label: 'Password',
                            hint: '*****************',
                            obscureText: true,
                            controller: authController.loginPasswordController,
                          ),
                          const SizedBox(height: 35),

                          // Create Account Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 12,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Get.toNamed(RoutePath.signUp);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(
                                      0.05,
                                    ), // Slight blue tint
                                    border: Border.all(
                                      color: Colors.blue.withOpacity(0.5),
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    "Create Account",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 3. Spacer pushes the button to the bottom
                    const Spacer(),

                    // 4. Sign In Button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25.0,
                        vertical: 40,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: Obx(
                          () => ElevatedButton(
                            onPressed: authController.isLoading.value
                                ? null
                                : authController.login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: authController.isLoading.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// HELPER WIDGETS TO MATCH THE EXACT UI
// ==========================================

/// Exact implementation of the pill-shaped text fields shown in the image
class _PillTextField extends StatefulWidget {
  final String label;
  final String hint;
  final bool obscureText;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const _PillTextField({
    required this.label,
    required this.hint,
    this.obscureText = false,
    required this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<_PillTextField> createState() => _PillTextFieldState();
}

class _PillTextFieldState extends State<_PillTextField> {
  late bool _isObscure;

  @override
  void initState() {
    super.initState();
    _isObscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _isObscure,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        labelStyle: const TextStyle(color: Colors.black87, fontSize: 14),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 25,
          vertical: 20,
        ),

        // Outlined Border to create the pill shape
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _isObscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _isObscure = !_isObscure;
                  });
                },
              )
            : null,
      ),
    );
  }
}

/// The Custom Header with the curved bottom, back button, logo, and rings
/// The Custom Header with the curved bottom, back button, logo, and rings
/// The Custom Header with the curved bottom, image logo, and corner rings
class _LoginHeader extends StatelessWidget {
  const _LoginHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ClipPath(
      clipper: _HeaderClipper(),
      child: Container(
        height: size.height * 0.30,
        width: double.infinity,
        color: const Color(0xFF2B80FF),
        child: Stack(
          children: [
            // Top Left Rings
            Positioned(
              left: -size.width * 0.50,
              top: -size.width * 0.50,
              child: const _HeaderCircles(),
            ),
            // Bottom Right Rings
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
      size.width / 2,
      size.height,
      size.width,
      size.height - 40,
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
  const _HeaderCircles();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(
        MediaQuery.of(context).size.width * 0.8,
        MediaQuery.of(context).size.width * 0.8,
      ),
      painter: _DashedCirclesPainter(),
    );
  }
}

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
