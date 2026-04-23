import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  void _showConfirmationDialog(BuildContext context, String title, VoidCallback onYes) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDialogButton(
                      'Yes',
                      onPressed: () {
                        Navigator.pop(context);
                        onYes();
                      },
                    ),
                    _buildDialogButton(
                      'No',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogButton(String text, {required VoidCallback onPressed}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color(0xFFE3F2FD), 
            side: const BorderSide(color: AppColors.primaryBlue, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using the exact light grey background from the design
      backgroundColor: const Color(0xFFF4F5F7), 
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header and Avatar Stack
            SizedBox(
              height: 290,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. The Convex Arch Header
                  ClipPath(
                    clipper: _ProfileArchClipper(),
                    child: Container(
                      height: 240,
                      width: double.infinity,
                      color: AppColors.primaryBlue,
                      child: const SafeArea(
                        bottom: false,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.only(top: 15.0),
                            child: Text(
                              'Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // 2. The Center Avatar
                  Positioned(
                    top: 110, // Adjust this to sit perfectly on the curve's peak
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 65,
                          // Make sure the image covers the circle completely
                          backgroundImage: NetworkImage(
                            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),
            
            // User Details
            const Text(
              'Isha',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '+91 5678 765 884',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
            
            const SizedBox(height: 35),
            
            // Menu Items List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.security,
                    title: 'Privacy Policy',
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    icon: Icons.receipt_long, // Changed to match document better
                    title: 'Terms and Conditions',
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    icon: Icons.support_agent,
                    title: 'Support',
                    onTap: () {},
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Action Items
                  _buildActionItem(
                    title: 'Delete Account',
                    onTap: () {
                      _showConfirmationDialog(
                        context,
                        'Delete Account',
                        () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildActionItem(
                    title: 'Logout',
                    onTap: () {
                      _showConfirmationDialog(
                        context,
                        'Log Out',
                        () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the blue-bordered menu items with a solid right arrow
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30), // Pill shape
          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.4), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.play_arrow, color: AppColors.primaryBlue, size: 18),
          ],
        ),
      ),
    );
  }

  /// Builds the red-bordered action items (Delete / Logout)
  Widget _buildActionItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30), // Pill shape
          // Subtle red border exactly like the image
          border: Border.all(color: const Color(0xFFFF4B4B).withOpacity(0.6), width: 1),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFF4B4B),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Cuts the bottom of the container into a convex arch (hill shape)
class _ProfileArchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    
    // Start at top left
    path.lineTo(0, 0);
    
    // Draw line down to the bottom left edge
    path.lineTo(0, size.height);

    // Curve upwards into a hill in the center, and back down to the right edge
    path.quadraticBezierTo(
      size.width / 2, size.height - 110, // The control point pulls the curve UP
      size.width, size.height             // Ends at the bottom right edge
    );

    // Draw line up to top right
    path.lineTo(size.width, 0);
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}