import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'call_screen.dart';

class CallsHistoryScreen extends StatelessWidget {
  const CallsHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: const Text(
          'Calls',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CallScreen(),
              ),
            );
          },
          child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: AppColors.avatarRed,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'J',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Jhon',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '10 Feb | 12:55 PM',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '01:00:98',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
