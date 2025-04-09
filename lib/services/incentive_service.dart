import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class IncentiveService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;
  
  // Get user's current incentive balance
  Future<double> getUserIncentiveBalance() async {
    if (_userId == null) return 0.0;
    
    try {
      final doc = await _firestore.collection('users').doc(_userId).get();
      return (doc.data()?['incentives'] ?? 0).toDouble();
    } catch (e) {
      debugPrint('Error getting incentive balance: $e');
      return 0.0;
    }
  }
  
  // Get user's transaction history
  Stream<List<IncentiveTransaction>> getTransactionHistory() {
    if (_userId == null) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: _userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return IncentiveTransaction(
              id: doc.id,
              title: data['title'],
              description: data['description'],
              amount: data['amount'].toDouble(),
              timestamp: (data['timestamp'] as Timestamp).toDate(),
              isCredit: data['isCredit'],
            );
          }).toList();
        });
  }
  
  // Redeem incentives
  Future<Map<String, dynamic>> redeemIncentives({
    required String method,
    required double amount,
    required String details,
  }) async {
    if (_userId == null) {
      return {
        'success': false,
        'message': 'You must be logged in to redeem incentives.',
      };
    }
    
    try {
      // Get current balance
      final userDoc = await _firestore.collection('users').doc(_userId).get();
      final currentBalance = (userDoc.data()?['incentives'] ?? 0).toDouble();
      
      // Check if user has enough balance
      if (currentBalance < amount) {
        return {
          'success': false,
          'message': 'Insufficient balance. Your current balance is ₹$currentBalance.',
        };
      }
      
      // Create a batch to perform multiple operations
      final batch = _firestore.batch();
      
      // Update user's balance
      batch.update(_firestore.collection('users').doc(_userId), {
        'incentives': FieldValue.increment(-amount),
      });
      
      // Create a transaction record
      final transactionRef = _firestore.collection('transactions').doc();
      batch.set(transactionRef, {
        'userId': _userId,
        'title': 'Redemption',
        'description': '$method: $details',
        'amount': amount,
        'timestamp': FieldValue.serverTimestamp(),
        'isCredit': false,
        'method': method,
        'details': details,
        'status': 'processing',
      });
      
      // Create a redemption request
      final redemptionRef = _firestore.collection('redemptions').doc();
      batch.set(redemptionRef, {
        'userId': _userId,
        'amount': amount,
        'method': method,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
        'transactionId': transactionRef.id,
      });
      
      // Commit the batch
      await batch.commit();
      
      return {
        'success': true,
        'message': 'Redemption request submitted successfully! It will be processed within 24-48 hours.',
      };
    } catch (e) {
      debugPrint('Error redeeming incentives: $e');
      return {
        'success': false,
        'message': 'Failed to process redemption. Please try again.',
      };
    }
  }
  
  // Get user's reward tier
  Future<Map<String, dynamic>> getUserRewardTier() async {
    if (_userId == null) {
      return {
        'tier': 'Bronze',
        'reportsCount': 0,
        'nextTier': 'Silver',
        'reportsNeeded': 10,
        'rewardPerReport': 15,
      };
    }
    
    try {
      final doc = await _firestore.collection('users').doc(_userId).get();
      final reportsCount = doc.data()?['reportsCount'] ?? 0;
      
      if (reportsCount >= 51) {
        return {
          'tier': 'Platinum',
          'reportsCount': reportsCount,
          'nextTier': null,
          'reportsNeeded': 0,
          'rewardPerReport': 60,
        };
      } else if (reportsCount >= 26) {
        return {
          'tier': 'Gold',
          'reportsCount': reportsCount,
          'nextTier': 'Platinum',
          'reportsNeeded': 51 - reportsCount,
          'rewardPerReport': 40,
        };
      } else if (reportsCount >= 11) {
        return {
          'tier': 'Silver',
          'reportsCount': reportsCount,
          'nextTier': 'Gold',
          'reportsNeeded': 26 - reportsCount,
          'rewardPerReport': 25,
        };
      } else {
        return {
          'tier': 'Bronze',
          'reportsCount': reportsCount,
          'nextTier': 'Silver',
          'reportsNeeded': 11 - reportsCount,
          'rewardPerReport': 15,
        };
      }
    } catch (e) {
      debugPrint('Error getting reward tier: $e');
      return {
        'tier': 'Bronze',
        'reportsCount': 0,
        'nextTier': 'Silver',
        'reportsNeeded': 10,
        'rewardPerReport': 15,
      };
    }
  }
}

class IncentiveTransaction {
  final String id;
  final String title;
  final String description;
  final double amount;
  final DateTime timestamp;
  final bool isCredit;
  
  IncentiveTransaction({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.timestamp,
    required this.isCredit,
  });
}

