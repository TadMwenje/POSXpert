import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({Key? key}) : super(key: key);

  static Future<void> _logLogoutEvent(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('user_logs').add({
        'user_id': user.uid,
        'email': user.email,
        'action': 'logout',
        'timestamp': FieldValue.serverTimestamp(),
        'device_info': {
          'platform': Theme.of(context).platform.toString(),
          'time': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        },
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF363753),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Logging out...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> logout(BuildContext context) async {
    // Show logout screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LogoutScreen()),
    );

    try {
      // Log the logout event
      await _logLogoutEvent(context);

      // Perform logout
      await FirebaseAuth.instance.signOut();

      // Navigate to login screen
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      // If logout fails, still go to login but show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: ${e.toString()}')),
      );
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}
