import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../auth/controller/auth_controller.dart';
import '../core/app_colors.dart';
import 'home_screen.dart';
import 'calls_history_screen.dart';
import 'profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final _authController = Get.find<AuthController>();

  final List<Widget> _screens = [
    const HomeScreen(),
    const CallsHistoryScreen(),
    const ProfileScreen(),
  ];

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _refreshTabData(index);
  }

  // Tab widgets are kept alive (so their state survives switches), but the
  // user expects fresh data each time they land on a tab — so we re-fire the
  // same loaders that initState would call.
  void _refreshTabData(int index) {
    switch (index) {
      case 0: // Home
        _authController.checkIsLogin();
        _authController.fetchRecentCalls(refresh: true);
        break;
      case 1: // Calls
        _authController.fetchCallHistory(refresh: true);
        break;
      case 2: // Profile
        _authController.checkIsLogin();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: Colors.grey.shade400,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phone),
            label: 'Calls',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
