import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kathoram/features/newfeature/auth/controller/auth_controller.dart';
import 'package:kathoram/features/newfeature/auth/model/recent_call_model.dart';
import 'package:kathoram/features/newfeature/core/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final authController = Get.find<AuthController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    authController.fetchRecentCalls(refresh: true);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      authController.fetchRecentCalls();
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
      body: RefreshIndicator(
        onRefresh: () async {
          await authController.checkIsLogin();
          await authController.fetchRecentCalls(refresh: true);
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                height: 180,
                width: double.infinity,
                child: SafeArea(
                  bottom: false,
                  child: Center(
                    child: Image.asset('assets/png/Group 21128.png'),
                  ),
                ),
              ),
              Padding(
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
                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _buildOnlineToggle(),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Coins Collected',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Day Call
                                Obx(() {
                                  final coins =
                                      authController.userProfile.value?.staffCoins;
                                  final dayCoins = coins?.dayCoins ?? 0;
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'Day Call : ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      _buildCoinIcon(),
                                      const SizedBox(width: 6),
                                      Text(
                                        _formatCoins(dayCoins),
                                        style: const TextStyle(
                                          color: AppColors.primaryBlue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  );
                                }),

                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: Color(0xFFEEEEEE),
                                  ),
                                ),

                                // Night Call
                                Obx(() {
                                  final coins =
                                      authController.userProfile.value?.staffCoins;
                                  final nightCoins = coins?.nightCoins ?? 0;
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'Night Call : ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      _buildCoinIcon(),
                                      const SizedBox(width: 6),
                                      Text(
                                        _formatCoins(nightCoins),
                                        style: const TextStyle(
                                          color: AppColors.primaryBlue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Recent Calls Divider
                    Row(
                      children: const [
                        Expanded(
                          child: Divider(color: Color(0xFFE0E0E0), thickness: 1),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            'Recent Calls',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: Color(0xFFE0E0E0), thickness: 1),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Recent Calls List (API driven)
                    Obx(() {
                      final list = authController.recentCallsList;
                      final isLoading =
                          authController.isLoadingRecentCalls.value;

                      if (isLoading && list.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (list.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Center(
                            child: Text(
                              'No recent calls',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          for (var i = 0; i < list.length; i++) ...[
                            _buildRecentCallCard(list[i]),
                            if (i < list.length - 1) const SizedBox(height: 15),
                          ],
                          if (authController.hasMoreRecentCalls.value)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: isLoading
                                    ? const CircularProgressIndicator()
                                    : const SizedBox.shrink(),
                              ),
                            ),
                        ],
                      );
                    }),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================

  String _formatCoins(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  Widget _buildOnlineToggle() {
    return Obx(() {
      final isOnline = authController.isOnlineStatus.value;
      return GestureDetector(
        onTap: () {
          authController.toggleOnlineStatus(!isOnline);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 112,
          height: 31,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isOnline ? AppColors.onlineGreen : AppColors.offlineRed,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                left: isOnline ? 12 : null,
                right: !isOnline ? 10 : null,
                child: Text(
                  isOnline ? 'Online' : 'Offline',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                right: isOnline ? 2 : null,
                left: !isOnline ? 2 : null,
                child: Container(
                  width: 26,
                  height: 26,
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
    });
  }

  Widget _buildCoinIcon() {
    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFDE9E36),
      ),
      child: const Icon(
        Icons.mic,
        size: 11,
        color: Colors.white,
      ),
    );
  }

  Widget _buildRecentCallCard(RecentCallItem item) {
    final name = item.callerDetails.name.isNotEmpty
        ? item.callerDetails.name
        : 'Unknown';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final color = _getAvatarColor(initial);

    final dateStr = item.createdAt > 0
        ? DateFormat('dd MMM | hh:mm a')
            .format(DateTime.fromMillisecondsSinceEpoch(item.createdAt))
        : '';

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
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (dateStr.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
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
                  _formatDuration(item.duration),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
