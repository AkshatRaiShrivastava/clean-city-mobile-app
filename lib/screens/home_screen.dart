import 'dart:developer';

import 'package:cleancity/services/incentive_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cleancity/services/auth_service.dart';
import 'package:cleancity/services/report_service.dart';
import 'package:cleancity/models/report.dart';
import 'package:cleancity/screens/report_detail_screen.dart';
import 'package:cleancity/widgets/report_card.dart';
import 'package:cleancity/screens/reports_screen.dart';
import 'package:cleancity/screens/camera_screen.dart';
import 'package:cleancity/screens/incentives_screen.dart';
import 'package:cleancity/screens/settings_screen.dart';
import 'package:cleancity/screens/ai_recycle_screen.dart';
import 'package:badges/badges.dart' as badges;

// Create a NotificationService to handle the notification count
// class NotificationService extends ChangeNotifier {
//   int _unreadCount = 1;

//   int get unreadCount => _unreadCount;

//   Future<void> fetchUnreadCount() async {
//     // Implement fetching unread notifications count from your backend
//     // Update _unreadCount and notify listeners
//   }
// }

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = [
    const HomeScreen(),
    const ReportsScreen(),
    const CameraScreen(),
    const AIRecycleScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // When camera button is pressed, show the camera screen but don't change selected index
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CameraScreen()),
      );
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            activeIcon: Icon(Icons.description),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              maxRadius: 30,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.camera_alt_outlined, size: 30),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            // icon: Image.asset('assets/icons/recycle_with_ai.svg',scale: 0.5,),
            icon: Icon(Icons.recycling_outlined),
            activeIcon: Icon(Icons.recycling_outlined),
            label: 'AI Reuse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final reportService = ReportService();
    // final notificationService = Provider.of<NotificationService>(context);

    return Scaffold(
      appBar: AppBar(
        // leading: IconButton(
        //   icon: const Icon(Icons.menu),
        //   onPressed: () {
        //     // Implement menu functionality
        //   },
        // ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 30,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.eco, color: Colors.blueAccent, size: 30);
              },
            ),
            const SizedBox(width: 8),
            const Text('CleanCity'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: badges.Badge(
              showBadge: false,
              badgeContent: Text(
                '1',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              badgeStyle: const badges.BadgeStyle(
                badgeColor: Colors.red,
                padding: EdgeInsets.all(5),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  // Navigate to notifications screen
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  // );
                },
              ),
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: authService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Incentives Section
                FutureBuilder<double>(
                  future: IncentiveService().getUserIncentiveBalance(),
                  builder: (context, snapshot) {
                    final incentiveAmount = snapshot.data ?? 0.0;

                    return Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Icon(
                              Icons.redeem,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your Incentives',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '₹${incentiveAmount.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const IncentivesScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue[800],
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Redeem'),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Reports Section Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Reports',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ReportsScreen()),
                          );
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                ),

                // Reports List
                Expanded(
                  child: StreamBuilder<List<Report>>(
                    stream: reportService.getAllReports(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        log(snapshot.error.toString());
                        return Center(
                          child: Text(
                            'Error loading reports: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      final reports = snapshot.data ?? [];

                      if (reports.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.description_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No reports yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Tap the camera button to report garbage',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const CameraScreen()),
                                  );
                                },
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Report Now'),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: reports.length,
                        itemBuilder: (context, index) {
                          final report = reports[index];
                          return ReportCard(
                            report: report,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ReportDetailScreen(reportId: report.id),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
