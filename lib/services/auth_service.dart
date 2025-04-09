import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;

  AuthService() {
    // Initialize the auth state
    _user = _auth.currentUser;
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        await _loadUserData();
        // Update SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
      } else {
        _userData = null;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', false);
      }
      notifyListeners();
    });
  }

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _loadUserData() async {
    if (_user == null) return;

    try {
      setLoading(true);
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        _userData = doc.data();
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String phoneNumber,
    required String aadhaarNumber,
    required String name,
  }) async {
    try {
      setLoading(true);

      // First create the user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to create user');
      }

      // Then create the user document in Firestore
      final userData = {
        'name': name.trim(),
        'email': email.trim(),
        'phoneNumber': phoneNumber.trim(),
        'aadhaarNumber': aadhaarNumber.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'incentives': 0,
        'reportsCount': 0,
        'uid': userCredential.user!.uid,
      };

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData);

      _userData = userData;
      notifyListeners();

      return {
        'success': true,
        'message': 'Account created successfully!',
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      return {
        'success': false,
        'message': (e.code),
      };
    } catch (e) {
      debugPrint('Registration Error: $e');
      return {
        'success': false,
        'message':
            'Failed to create account. Please try again. ${e.toString()}',
      };
    } finally {
      setLoading(false);
    }
  }

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      setLoading(true);

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _loadUserData();

      // Save login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      return {
        'success': true,
        'message': 'Signed in successfully!',
      };
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided.';
          break;
        case 'invalid-email':
          message = 'The email address is invalid.';
          break;
        case 'user-disabled':
          message = 'This user has been disabled.';
          break;
        default:
          message = 'An error occurred during sign in. Please try again.';
      }

      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
      };
    } finally {
      setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();

      // Clear login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      setLoading(true);
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      debugPrint('Error resetting password: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> updateUserProfile({
    String? name,
    String? phoneNumber,
  }) async {
    if (_user == null) return;

    try {
      setLoading(true);

      Map<String, dynamic> updateData = {};

      if (name != null && name.isNotEmpty) {
        updateData['name'] = name;
      }

      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        updateData['phoneNumber'] = phoneNumber;
      }

      if (updateData.isNotEmpty) {
        await _firestore.collection('users').doc(_user!.uid).update(updateData);
        await _loadUserData();
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<bool> isUserLoggedIn() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _loadUserData();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking auth state: $e');
      return false;
    }
  }
}
