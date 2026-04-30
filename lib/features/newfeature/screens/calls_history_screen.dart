import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../auth/controller/auth_controller.dart';
import '../auth/model/call_history_model.dart';
import '../core/app_colors.dart';

class CallsHistoryScreen extends StatefulWidget {
  const CallsHistoryScreen({Key? key}) : super(key: key);

  @override
  State<CallsHistoryScreen> createState() => _CallsHistoryScreenState();
}

class _CallsHistoryScreenState extends State<CallsHistoryScreen> {
  final authController = Get.find<AuthController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    authController.fetchCallHistory(refresh: true);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      authController.fetchCallHistory();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

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
      body: Obx(() {
        final callList = authController.callHistoryList;
        final isLoading = authController.isLoadingCallHistory.value;

        if (isLoading && callList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (callList.isEmpty) {
          return const Center(
            child: Text(
              'No call history found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => authController.fetchCallHistory(refresh: true),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            itemCount: callList.length + (authController.hasMoreCallHistory.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == callList.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final item = callList[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildCallHistoryCard(item),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildCallHistoryCard(CallHistoryItem item) {
    final callerName = item.callerDetails.name.isNotEmpty
        ? item.callerDetails.name
        : 'Unknown';
    final initial = callerName.isNotEmpty ? callerName[0].toUpperCase() : '?';
    final avatarColor = _getAvatarColor(initial);

    // Format date
    final dateTime = DateTime.fromMillisecondsSinceEpoch(item.startTime);
    final dateStr = DateFormat('dd MMM | hh:mm a').format(dateTime);

    // Format duration
    final durationStr = _formatDuration(item.duration);

    // Status icon and color
    final statusInfo = _getStatusInfo(item.status);

    return Container(
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: avatarColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Name and phone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  callerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(statusInfo['icon'] as IconData,
                        size: 14, color: statusInfo['color'] as Color),
                    const SizedBox(width: 4),
                    Text(
                      item.status,
                      style: TextStyle(
                        color: statusInfo['color'] as Color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Date and duration
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dateStr,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              if (item.duration > 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 13,
                      color: Colors.black87,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      durationStr,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              if (item.coinsUsed > 0) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFDE9E36),
                      ),
                      child: const Icon(Icons.attach_money,
                          size: 9, color: Colors.white),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.coinsUsed}',
                      style: const TextStyle(
                        color: Color(0xFFDE9E36),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status.toUpperCase()) {
      case 'ENDED':
        return {
          'icon': Icons.call_end,
          'color': AppColors.avatarGreen,
        };
      case 'MISSED':
        return {
          'icon': Icons.call_missed,
          'color': AppColors.offlineRed,
        };
      case 'CANCELLED':
        return {
          'icon': Icons.cancel_outlined,
          'color': Colors.orange,
        };
      case 'ONGOING':
        return {
          'icon': Icons.call,
          'color': AppColors.onlineGreen,
        };
      default:
        return {
          'icon': Icons.phone,
          'color': Colors.grey,
        };
    }
  }

  Color _getAvatarColor(String initial) {
    final colors = [
      AppColors.avatarRed,
      AppColors.avatarGreen,
      AppColors.avatarGold,
      AppColors.primaryBlue,
      const Color(0xFF9C27B0),
    ];
    return colors[initial.codeUnitAt(0) % colors.length];
  }
}
