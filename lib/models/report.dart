import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportStatus {
  pending,
  underVerification,
  verified, // Make sure this exists
  action_taken,
  resolved,
  rejected,
}

class Report {
  final String id;
  final String imageUrl;
  final String type;
  final ReportStatus status;
  final DateTime dateReported;
  final String location;
  final double latitude;
  final double longitude;
  final String description;
  final String userId;
  final List<StatusUpdate> statusUpdates;
  final List<Comment> comments;

  Report({
    required this.id,
    required this.imageUrl,
    required this.type,
    required this.status,
    required this.dateReported,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.userId,
    required this.statusUpdates,
    required this.comments,
  });

  factory Report.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Report(
      id: doc.id,
      imageUrl: data['imageUrl'] ?? '',
      type: data['type'] ?? 'Other',
      status: _parseStatus(data['status'] ?? 'pending'),
      dateReported:
          (data['dateReported'] as Timestamp?)?.toDate() ?? DateTime.now(),
      location: data['location'] ?? 'Unknown',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] ?? '',
      userId: data['userId'] ?? '',
      statusUpdates: _parseStatusUpdates(data['statusUpdates']),
      comments: _parseComments(data['comments']),
    );
  }

  static ReportStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ReportStatus.pending;
      case 'under_verification':
        return ReportStatus.underVerification;
      case 'verified':
        return ReportStatus.verified;
      case 'action_taken':
        return ReportStatus.action_taken;
      case 'resolved':
        return ReportStatus.resolved;
      case 'rejected':
        return ReportStatus.rejected;
      default:
        return ReportStatus.pending;
    }
  }

  static List<StatusUpdate> _parseStatusUpdates(dynamic updates) {
    if (updates == null || !(updates is List)) return [];

    return (updates as List).map((update) {
      if (update is! Map) return StatusUpdate.empty();

      return StatusUpdate(
        status: _parseStatus(update['status']?.toString() ?? 'pending'),
        timestamp:
            (update['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        description: update['description']?.toString() ?? '',
      );
    }).toList();
  }

  static List<Comment> _parseComments(dynamic comments) {
    if (comments == null || !(comments is List)) return [];

    return (comments as List).map((comment) {
      if (comment is! Map) return Comment.empty();

      return Comment(
        author: comment['author']?.toString() ?? 'Anonymous',
        timestamp:
            (comment['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        content: comment['content']?.toString() ?? '',
      );
    }).toList();
  }
}

class StatusUpdate {
  final ReportStatus status;
  final DateTime timestamp;
  final String description;

  StatusUpdate({
    required this.status,
    required this.timestamp,
    required this.description,
  });

  static StatusUpdate empty() {
    return StatusUpdate(
      status: ReportStatus.pending,
      timestamp: DateTime.now(),
      description: '',
    );
  }
}

class Comment {
  final String author;
  final DateTime timestamp;
  final String content;

  Comment({
    required this.author,
    required this.timestamp,
    required this.content,
  });

  static Comment empty() {
    return Comment(
      author: 'Anonymous',
      timestamp: DateTime.now(),
      content: '',
    );
  }
}
