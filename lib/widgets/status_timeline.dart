import 'package:flutter/material.dart';
import 'package:cleancity/models/report.dart';
import 'package:intl/intl.dart';

class StatusTimeline extends StatelessWidget {
  final List<StatusUpdate> statusUpdates;

  const StatusTimeline({
    super.key,
    required this.statusUpdates,
  });

  @override
  Widget build(BuildContext context) {
    // Sort the status updates by timestamp (most recent last)
    final sortedUpdates = List<StatusUpdate>.from(statusUpdates)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sortedUpdates.length,
        itemBuilder: (context, index) {
          final update = sortedUpdates[index];
          final isLast = index == sortedUpdates.length - 1;
          
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline connector
                SizedBox(
                  width: 40,
                  child: Column(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _getStatusColor(update.status),
                          shape: BoxShape.circle,
                        ),
                        child: isLast
                            ? const Icon(Icons.check, color: Colors.white, size: 14)
                            : null,
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: Colors.grey[300],
                            margin: const EdgeInsets.symmetric(vertical: 4),
                          ),
                        ),
                    ],
                  ),
                ),
                // Status content
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getStatusString(update.status),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(update.status),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          update.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM dd, yyyy - HH:mm').format(update.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
  
  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return Colors.orange;
      case ReportStatus.underVerification:
        return Colors.blue;
      case ReportStatus.verified:
        return Colors.indigo;
      case ReportStatus.action_taken:
        return Colors.purple;
      case ReportStatus.resolved:
        return Colors.green;
      case ReportStatus.rejected:
        return Colors.red;
    }
  }
}

