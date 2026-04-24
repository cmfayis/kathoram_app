import 'package:flutter/material.dart';
import 'package:kathoram/features/newfeature/core/app_colors.dart';

// Assuming you have this imported in your real project
// import '../core/app_colors.dart';

// Temporary fallback colors if AppColors is not available


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isOnline = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. The Small Curved Header from Approval Screen
            const _SmallCurvedHeader(),
            
            // 2. Overlapping Content
            Padding(
              // Pushes the content down so it overlaps the bottom of the curve
              padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status and Coins Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Left Side: Online Switch
                        Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _buildOnlineToggle(),
                          ),
                        ),
                        
                        // Right Side: Coins Section
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // "Coins Collected" Pill
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Coins Collected', 
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)
                                ),
                              ),
                              const SizedBox(height: 12),
                              
                              // Day Call
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Text('Day Call : ', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                                  _buildCoinIcon(),
                                  const SizedBox(width: 6),
                                  const Text('100', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                              
                              // Subtle Divider
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                              ),
                              
                              // Night Call
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Text('Night Call : ', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                                  _buildCoinIcon(),
                                  const SizedBox(width: 6),
                                  const Text('100', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Active Call Card (Jhon)
                  _buildIncomingCallCard(
                    name: 'Jhon',
                    initial: 'J',
                    color: AppColors.avatarRed,
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // Recent Calls Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Color(0xFFE0E0E0), thickness: 1)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text('Recent Calls', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black87)),
                      ),
                      const Expanded(child: Divider(color: Color(0xFFE0E0E0), thickness: 1)),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Recent Calls List
                  _buildRecentCallCard(name: 'Ratheesh Kumar', initial: 'R', color: AppColors.avatarGreen),
                  const SizedBox(height: 15),
                  _buildRecentCallCard(name: 'Abdul Fayis', initial: 'R', color: AppColors.avatarGold),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================

  Widget _buildOnlineToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isOnline = !isOnline;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 85,
        height: 35,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isOnline ? AppColors.onlineGreen : AppColors.offlineRed,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Text changes side based on state
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: isOnline ? 12 : null,
              right: !isOnline ? 10 : null,
              child: Text(
                isOnline ? 'Online' : 'Offline', 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)
              ),
            ),
            // White circle handles sliding
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              right: isOnline ? 2 : null,
              left: !isOnline ? 2 : null,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinIcon() {
    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(
        shape: BoxShape.circle, 
        color: Color(0xFFDE9E36), // Exact gold from the image
      ),
      child: const Icon(Icons.mic, size: 11, color: Colors.white), // Mic inside the coin
    );
  }

  Widget _buildIncomingCallCard({required String name, required String initial, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color,
            child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 15),
          Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          
          const Spacer(),
          
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCallButton(text: 'Accept', color: AppColors.onlineGreen, icon: Icons.phone),
              const SizedBox(height: 8),
              _buildCallButton(text: 'Reject', color: AppColors.offlineRed, icon: Icons.phone_disabled_rounded), // Using an icon closer to "reject"
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCallButton({required String text, required Color color, required IconData icon}) {
    return Container(
      width: 90, // Explicit width to match the pill shape exactly
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: color, 
        borderRadius: BorderRadius.circular(20)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildRecentCallCard({required String name, required String initial, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color,
            child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 15),
          Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ==========================================
// HEADER CLASSES
// ==========================================

/// The exact small header from the Approval Screen
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
    path.lineTo(0, size.height - 40);
    
    path.quadraticBezierTo(
      size.width / 2, size.height + 15, 
      size.width, size.height - 40
    );
    
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}