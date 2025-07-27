import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ErrorLogger {
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> logError(String screen, dynamic error) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await _firestore.collection('error_logs').add({
        'user_id': user?.uid ?? 'not_logged_in',
        'screen': screen,
        'error': error.toString(),
        'timestamp': FieldValue.serverTimestamp(),
        'platform': 'flutter_web', // or 'flutter_android' etc.
      });
    } catch (e) {
      print('Failed to log error: $e');
    }
  }
}
