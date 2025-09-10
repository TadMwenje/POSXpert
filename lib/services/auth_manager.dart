import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_data.dart';

class AuthManager extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserData? _userData;
  bool _isLoading = false;
  String? _error;
  String? _userRole;

  UserData? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userRole => _userRole;
  bool get isAuthenticated => _userData != null && _userData!.uid.isNotEmpty;

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String? errorMessage) {
    if (_error != errorMessage) {
      _error = errorMessage;
      notifyListeners();
    }
  }

  Future<void> initializeUser() async {
    _setLoading(true);
    _setError(null);

    try {
      final User? firebaseUser = _auth.currentUser;

      if (firebaseUser == null) {
        _userData = null;
        _userRole = null;
        _setLoading(false);
        return;
      }

      // Check if email is verified
      if (!firebaseUser.emailVerified) {
        throw Exception('Email not verified. Please check your inbox.');
      }

      // Fetch user data and role
      await _fetchUserDataAndRole(firebaseUser.uid);
    } catch (e) {
      _setError('Failed to initialize user: ${e.toString()}');
      _userData = null;
      _userRole = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _fetchUserDataAndRole(String userId) async {
    try {
      final userDoc = await _firestore.collection('Employee').doc(userId).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;

        _userData = UserData(
          uid: userId,
          email: data['email']?.toString() ?? '',
          firstName: data['f_name']?.toString() ?? '',
          lastName: data['l_name']?.toString() ?? '',
          phone: data['phone']?.toString() ?? '',
          role: data['role']?.toString() ?? 'user',
          username: data['username']?.toString() ?? '',
          isActive: data['state']?.toString() == 'active',
          createdAt: data['created_at'] is Timestamp
              ? (data['created_at'] as Timestamp).toDate()
              : DateTime.now(),
        );

        _userRole = data['role']?.toString().toLowerCase();
      } else {
        throw Exception('User document not found');
      }
    } catch (e) {
      throw Exception('Failed to fetch user data: ${e.toString()}');
    }
  }

  Future<bool> signIn(
      String email, String password, BuildContext context) async {
    _setLoading(true);
    _setError(null);

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (userCredential.user != null) {
        // Check email verification
        if (!userCredential.user!.emailVerified) {
          await userCredential.user!.reload();
          if (!userCredential.user!.emailVerified) {
            throw Exception('Email not verified. Please check your inbox.');
          }
        }

        // Fetch user data and role
        await _fetchUserDataAndRole(userCredential.user!.uid);
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Login failed. Please try again.';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password. Please try again.';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'This account has been disabled.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      }
      _setError(errorMessage);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String username,
    required bool isAdmin,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (userCredential.user != null) {
        // Create user document in Firestore
        await _firestore
            .collection('Employee')
            .doc(userCredential.user!.uid)
            .set({
          'f_name': firstName,
          'l_name': lastName,
          'email': email,
          'phone': phone,
          'username': username,
          'role': isAdmin ? 'admin' : 'user',
          'state': 'active',
          'created_at': FieldValue.serverTimestamp(),
        });

        // Send verification email
        await userCredential.user!.sendEmailVerification();

        // Set user data
        _userData = UserData(
          uid: userCredential.user!.uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
          phone: phone,
          role: isAdmin ? 'admin' : 'user',
          username: username,
          isActive: true,
          createdAt: DateTime.now(),
        );

        _userRole = isAdmin ? 'admin' : 'user';

        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Registration failed. Please try again.';
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      }
      _setError(errorMessage);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);

    try {
      await _auth.signOut();
      _userData = null;
      _userRole = null;
    } catch (e) {
      _setError('Failed to sign out: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _setError(null);

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Password reset failed. Please try again.';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email.';
      }
      _setError(errorMessage);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> verifyEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw Exception('Failed to send verification email: ${e.toString()}');
    }
  }

  void clearError() {
    _setError(null);
  }

  // Check if user has permission for specific actions
  bool canAccessInventory() {
    return _userRole == 'admin' || _userRole == 'inventory';
  }

  bool canAccessOrders() {
    return _userRole == 'admin' || _userRole == 'cashier';
  }

  bool canAccessSettings() {
    return _userRole == 'admin';
  }

  bool canAccessReports() {
    return _userRole == 'admin' || _userRole == 'inventory';
  }

  bool canManageUsers() {
    return _userRole == 'admin';
  }
}
