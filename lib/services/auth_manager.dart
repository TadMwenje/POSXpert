import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_data.dart';
import 'auth_service.dart';

class AuthManager extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserData? _userData;
  bool _isLoading = false;
  String? _error;

  UserData? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _userData != null && _userData!.uid.isNotEmpty;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  Future<void> initializeUser() async {
    _setLoading(true);
    _setError(null);

    try {
      final User? firebaseUser = _authService.currentUser;

      if (firebaseUser == null) {
        _userData = null;
        _setLoading(false);
        return;
      }

      // Check if email is verified
      if (!firebaseUser.emailVerified) {
        throw Exception('Email not verified. Please check your inbox.');
      }

      _userData = await _authService.fetchUserData(firebaseUser.uid);
    } catch (e) {
      _setError('Failed to initialize user: ${e.toString()}');
      _userData = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn(
      String email, String password, BuildContext context) async {
    _setLoading(true);
    _setError(null);

    try {
      final userCredential =
          await _authService.signInWithEmailAndPassword(email, password);

      if (userCredential.user != null) {
        // Check email verification
        if (!userCredential.user!.emailVerified) {
          await userCredential.user!.reload();
          if (!userCredential.user!.emailVerified) {
            throw Exception('Email not verified. Please check your inbox.');
          }
        }

        _userData = await _authService.fetchUserData(userCredential.user!.uid);
        Provider.of<UserData>(context, listen: false);
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> registerWithVerification({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String username,
    required bool isAdmin,
    required BuildContext context,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final userCredential = await _authService.createUserWithEmailAndPassword(
        email,
        password,
        firstName,
        lastName,
        phone,
        username,
        isAdmin: isAdmin,
      );

      if (userCredential.user != null) {
        // Send verification email
        await _authService.verifyEmail();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut(BuildContext context) async {
    _setLoading(true);

    try {
      await _authService.signOut();
      _userData = null;
      Provider.of<UserData>(context, listen: false);
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
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
