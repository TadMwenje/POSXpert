import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_data.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword(
      String email,
      String password,
      String firstName,
      String lastName,
      String phone,
      String username,
      {bool isAdmin = false}) async {
    try {
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Send email verification
        await credential.user!.sendEmailVerification();

        await _firestore.collection('Employee').doc(credential.user!.uid).set({
          'email': email,
          'f_name': firstName,
          'l_name': lastName,
          'phone': phone,
          'role': isAdmin ? 'admin' : 'cashier',
          'username': username,
          'state': 'active',
          'created_at': FieldValue.serverTimestamp(),
          'email_verified': false,
        });
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  Future<void> verifyEmail() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<bool> checkEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> checkEmailVerification(User user) async {
    await user.reload();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserData> fetchUserData(String uid) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection('Employee').doc(uid).get();

      if (!doc.exists) {
        throw Exception('User data not found');
      }

      return UserData.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  Exception _handleFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email.');
      case 'wrong-password':
        return Exception('Incorrect password.');
      case 'email-already-in-use':
        return Exception('Email is already in use.');
      case 'weak-password':
        return Exception('Password is too weak.');
      case 'invalid-email':
        return Exception('Email address is invalid.');
      case 'user-disabled':
        return Exception('This user account has been disabled.');
      default:
        return Exception('Authentication failed: ${e.message}');
    }
  }
}
