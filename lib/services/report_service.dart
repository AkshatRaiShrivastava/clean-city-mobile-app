import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cleancity/models/report.dart';
import 'package:cleancity/services/cloudinary_service.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  Future<String> uploadReportImage(File imageFile) async {
    try {
      debugPrint('Preparing to upload image...');
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }

      final imageUrl = await CloudinaryService.uploadImage(imageFile);
      debugPrint('Image uploaded successfully: $imageUrl');
      return imageUrl;
    } catch (e) {
      debugPrint('Image Upload Error: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> createReport({
    required String description,
    required File imageFile,
    required GeoPoint location,
    required String userId,
  }) async {
    try {
      // Upload image to Cloudinary
      final imageUrl = await uploadReportImage(imageFile);

      // Create report document in Firestore
      await _firestore.collection('reports').add({
        'description': description,
        'imageUrl': imageUrl, // Store Cloudinary URL
        'location': location,
        'userId': userId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Create Report Error: $e');
      throw Exception('Failed to create report');
    }
  }

  // Submit a new report
  Future<Map<String, dynamic>> submitReport({
    required File imageFile,
    required String type,
    required String location,
    required double latitude,
    required double longitude,
    String? description,
  }) async {
    if (_userId == null) {
      return {
        'success': false,
        'message': 'You must be logged in to submit a report.',
      };
    }

    try {
      // Generate a unique ID for the report
      final String reportId = const Uuid().v4();

      // Upload image to Cloudinary
      final String imageUrl = await uploadReportImage(imageFile);

      // Create initial status update
      final StatusUpdate initialStatus = StatusUpdate(
        status: ReportStatus.pending,
        timestamp: DateTime.now(),
        description: 'Report submitted successfully',
      );

      // Create report document in Firestore
      await _firestore.collection('reports').doc(reportId).set({
        'id': reportId,
        'userId': _userId,
        'userName': _auth.currentUser!.displayName.toString(),
        'imageUrl': imageUrl,
        'type': type,
        'status': ReportStatus.pending.toString().split('.').last,
        'dateReported': FieldValue.serverTimestamp(),
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'description': description ?? '',
        'statusUpdates': [
          {
            'status': initialStatus.status.toString().split('.').last,
            'timestamp': initialStatus.timestamp,
            'description': initialStatus.description,
          }
        ],
        'comments': [],
      });

      // Update user's report count
      await _firestore.collection('users').doc(_userId).update({
        'reportsCount': FieldValue.increment(1),
      });

      return {
        'success': true,
        'message': 'Report submitted successfully!',
        'reportId': reportId,
      };
    } catch (e) {
      debugPrint('Error submitting report: $e');
      log(e.toString());
      return {
        'success': false,
        'message': 'Failed to submit report. Please try again.',
      };
    }
  }

  // Get all reports for the current user
  Stream<List<Report>> getUserReports() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('reports')
        .orderBy('dateReported', descending: true)
        .where('userId', isEqualTo: _userId.toString())
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return _reportFromFirestore(doc);
      }).toList();
    });
  }

  // Get all reports (for admin or public feed)
  Stream<List<Report>> getAllReports() {
    return _firestore
        .collection('reports')
        .orderBy('dateReported', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return _reportFromFirestore(doc);
      }).toList();
    });
  }

  // Get a single report by ID
  Stream<Report> getReportById(String reportId) {
    return _firestore
        .collection('reports')
        .doc(reportId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        debugPrint('Report not found: $reportId');
        throw Exception('Report not found or error parsing report: $reportId');
      }
      try {
        return Report.fromFirestore(doc);
      } catch (e) {
        debugPrint('Error parsing report: $e');
        throw Exception('Error parsing report: $e');
      }
    });
  }

  // Add a comment to a report
  Future<bool> addComment(String reportId, String content) async {
    if (_userId == null) return false;

    try {
      debugPrint('Adding comment to report: $reportId');

      // Get user data for the comment
      final userDoc = await _firestore.collection('users').doc(_userId).get();
      final userName = userDoc.data()?['name'] ?? 'Anonymous';

      // Create comment with current timestamp
      final comment = {
        'author': userName,
        'userId': _userId,
        'timestamp':
            Timestamp.now(), // Use Timestamp.now() instead of serverTimestamp
        'content': content.trim(),
      };

      // Add comment to the report
      await _firestore.collection('reports').doc(reportId).update({
        'comments': FieldValue.arrayUnion([comment]),
      });

      debugPrint('Comment added successfully');
      return true;
    } catch (e) {
      debugPrint('Error adding comment: $e');
      return false;
    }
  }

  // Helper method to convert Firestore document to Report object
  Report _reportFromFirestore(DocumentSnapshot doc) {
    try {
      debugPrint('Parsing document ID: ${doc.id}');
      final data = doc.data() as Map<String, dynamic>? ?? {};

      // Parse status updates safely
      List<StatusUpdate> statusUpdates = [];
      try {
        if (data['statusUpdates'] != null) {
          statusUpdates = (data['statusUpdates'] as List).map((update) {
            return StatusUpdate(
              status:
                  _parseReportStatus(update['status']?.toString() ?? 'pending'),
              timestamp: (update['timestamp'] is Timestamp)
                  ? (update['timestamp'] as Timestamp).toDate()
                  : DateTime.now(),
              description: update['description']?.toString() ?? '',
            );
          }).toList();
        }
      } catch (e) {
        debugPrint('Error parsing status updates: $e');
      }

      // Parse comments safely
      List<Comment> comments = [];
      try {
        if (data['comments'] != null) {
          comments = (data['comments'] as List).map((comment) {
            return Comment(
              author: comment['author']?.toString() ?? 'Anonymous',
              timestamp: (comment['timestamp'] is Timestamp)
                  ? (comment['timestamp'] as Timestamp).toDate()
                  : DateTime.now(),
              content: comment['content']?.toString() ?? '',
            );
          }).toList();
        }
      } catch (e) {
        debugPrint('Error parsing comments: $e');
      }

      // Get timestamp safely
      DateTime getDateTime(dynamic value) {
        if (value is Timestamp) {
          return value.toDate();
        } else if (value == null) {
          return DateTime.now();
        } else {
          return DateTime.now();
        }
      }

      // Create Report object with strict type checking
      return Report(
        id: doc.id, // Use document ID instead of data['id']
        imageUrl: data['imageUrl']?.toString() ?? '',
        type: data['type']?.toString() ?? 'other',
        status: _parseReportStatus(data['status']?.toString() ?? 'pending'),
        dateReported: getDateTime(data['dateReported']),
        location: data['location']?.toString() ?? '',
        latitude: (data['latitude'] is num)
            ? (data['latitude'] as num).toDouble()
            : 0.0,
        longitude: (data['longitude'] is num)
            ? (data['longitude'] as num).toDouble()
            : 0.0,
        description: data['description']?.toString() ?? '',
        userId: data['userId']?.toString() ?? '',
        statusUpdates: statusUpdates,
        comments: comments,
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing report document: $e');
      debugPrint('Stack trace: $stackTrace');

      // Return a default Report object with the document ID
      return Report(
        id: doc.id,
        imageUrl: '',
        type: 'error',
        status: ReportStatus.pending,
        dateReported: DateTime.now(),
        location: 'Error loading location',
        latitude: 0.0,
        longitude: 0.0,
        description: 'Error loading report data',
        userId: '',
        statusUpdates: [],
        comments: [],
      );
    }
  }

  // Add this helper method to safely parse numbers
  double parseDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return defaultValue;
      }
    }
    return defaultValue;
  }

  // Helper method to parse ReportStatus enum from string
  ReportStatus _parseReportStatus(String status) {
    switch (status) {
      case 'pending':
        return ReportStatus.pending;
      case 'underVerification':
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
}
