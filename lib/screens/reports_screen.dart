import 'package:flutter/material.dart';
import 'package:cleancity/services/report_service.dart';
import 'package:cleancity/models/report.dart';
import 'package:cleancity/screens/report_detail_screen.dart';
import 'package:cleancity/widgets/report_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ReportService _reportService = ReportService();
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
      ),
      body: Column(
        children: [
          // Status Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedFilter == 'All',
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() {
                        _selectedFilter = 'All';
                      });
                    }
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Pending'),
                  selected: _selectedFilter == 'Pending',
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() {
                        _selectedFilter = 'Pending';
                      });
                    }
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Under Verification'),
                  selected: _selectedFilter == 'Under Verification',
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() {
                        _selectedFilter = 'Under Verification';
                      });
                    }
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Verified'),
                  selected: _selectedFilter == 'Verified',
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() {
                        _selectedFilter = 'Verified';
                      });
                    }
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Action Taken'),
                  selected: _selectedFilter == 'Action Taken',
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() {
                        _selectedFilter = 'Action Taken';
                      });
                    }
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Resolved'),
                  selected: _selectedFilter == 'Resolved',
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() {
                        _selectedFilter = 'Resolved';
                      });
                    }
                  },
                ),
              ],
            ),
          ),

          // Reports List
          Expanded(
            child: StreamBuilder<List<Report>>(
              stream: _reportService.getUserReports(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading reports: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final allReports = snapshot.data ?? [];

                if (allReports.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No reports yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Filter reports based on selected filter
                final filteredReports = _selectedFilter == 'All'
                    ? allReports
                    : allReports.where((report) {
                        final status = _getStatusString(report.status);
                        return status == _selectedFilter;
                      }).toList();

                if (filteredReports.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.filter_list,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No $_selectedFilter reports',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filteredReports.length,
                  itemBuilder: (context, index) {
                    final report = filteredReports[index];
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

  String _getStatusString(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.underVerification:
        return 'Under Verification';
      case ReportStatus.verified:
        return 'Verified';
      case ReportStatus.action_taken:
        return 'Action Taken';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.rejected:
        return 'Rejected';
    }
  }
}
