import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kathoram/screens/main_layout.dart';

class ApprovalPendingScreen extends StatefulWidget {
  const ApprovalPendingScreen({Key? key}) : super(key: key);

  @override
  State<ApprovalPendingScreen> createState() => _ApprovalPendingScreenState();
}

class _ApprovalPendingScreenState extends State<ApprovalPendingScreen> {

  @override
  void initState() {
    Timer(const Duration(seconds: 4), () {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MainLayout()));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Light grey background for the whole screen
      backgroundColor: const Color(0xFFF4F5F7), 
      
      // Custom Bottom Navigation Bar
      
      body: Column(
        children: [
          // 1. The Top Curved Header
          const _SmallCurvedHeader(),
          
          // 2. The Centered Approval Card
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 30.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBEBEB), // Card background color
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Hourglass Icon
                      Icon(
                        Icons.hourglass_empty_rounded,
                        size: 60,
                        color: Colors.black87,
                      ),
                      SizedBox(height: 25),
                      
                      // Title
                      Text(
                        'Approval Pending',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 15),
                      
                      // Subtitle text
                      Text(
                        'Your Request For Executive\nAccess Is Pending, Please Wait\nTill Accepting the Request',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.4, // Line height for readability
                          color: Colors.black54,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// CUSTOM WIDGETS FOR THIS SCREEN
// ==========================================

/// A smaller curved header specific to the internal app screens
class _SmallCurvedHeader extends StatelessWidget {
  const _SmallCurvedHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _SmallHeaderClipper(),
      child: Container(
        height: 180, // Shorter height than the login header
        width: double.infinity,
        color: const Color(0xFF2B80FF), // Primary blue
        child: SafeArea(
          bottom: false,
          child: Center(
            child: Image.asset('assets/png/Group 21128.png')
          ),
        ),
      ),
    );
  }
}

/// A clipper for the smaller header curve
class _SmallHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    
    path.quadraticBezierTo(
      size.width / 2, size.height + 10, 
      size.width, size.height - 30
    );
    
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

