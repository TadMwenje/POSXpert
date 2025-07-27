import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserManagementService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new user with specified role
  Future<UserCredential> addUser({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
    required String username,
    required bool isActive,
  }) async {
    try {
      // 1. Create the authentication user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Create the Firestore document for the user
      await _firestore
          .collection('Employee')
          .doc(userCredential.user!.uid)
          .set({
        'f_name': fullName.split(' ').first,
        'l_name': fullName.split(' ').length > 1
            ? fullName.split(' ').sublist(1).join(' ')
            : '',
        'email': email,
        'phone': phone,
        'role': role,
        'username': username,
        'state': isActive ? 'active' : 'inactive',
        'created_at': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } catch (e) {
      rethrow; // Re-throw the exception to be caught by the caller
    }
  }

  // Check if this is the first user in the system
  Future<bool> isFirstUser() async {
    try {
      // Check if any admin exists
      final adminQuery = await _firestore
          .collection('Employee')
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();

      // Also check for first user marker
      final firstUserDoc =
          await _firestore.collection('Employee').doc('__firstUser__').get();

      // If no admins and no marker, this is the first user
      return adminQuery.docs.isEmpty && !firstUserDoc.exists;
    } catch (e) {
      print('Error checking first user: $e');
      return true; // If there's an error accessing Firestore, assume this is the first user
    }
  }

  // Get current user's role
  Future<String> getCurrentUserRole() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      DocumentSnapshot userDoc =
          await _firestore.collection('Employee').doc(user.uid).get();

      if (!userDoc.exists) {
        throw Exception('User document does not exist');
      }

      return userDoc.get('role') as String;
    } catch (e) {
      print('Error getting user role: $e');
      throw Exception('Failed to get user role');
    }
  }

  // Update user role
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await _firestore.collection('Employee').doc(userId).update({
        'role': newRole,
      });
    } catch (e) {
      print('Error updating user role: $e');
      throw Exception('Failed to update user role');
    }
  }

  // Get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection('Employee').get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add the document ID to the data
        return data;
      }).toList();
    } catch (e) {
      print('Error getting all users: $e');
      throw Exception('Failed to get users');
    }
  }

  Future<void> resetUserPassword(String userId, String newPassword) async {
    // Implement the logic to reset the user's password
    // Example: Call an API or update the database
    print('Resetting password for user $userId to $newPassword');
  }

  Future<void> updateUserStatus(String userId, bool isActive) async {
    // Implement the logic to update the user's status in the database or API
    // Example:
    print(
        'Updating user $userId status to ${isActive ? 'active' : 'inactive'}');
    await Future.delayed(Duration(seconds: 1)); // Simulate API call
  }

  Future<void> deleteUser(String userId) async {
    // Implement the logic to delete a user, e.g., make an API call
    // Example:
    // await http.delete(Uri.parse('https://api.example.com/users/$userId'));
    print(
        'User with ID $userId deleted'); // Placeholder for actual implementation
  }

  // Mark first user setup complete
  Future<void> markFirstUserSetupComplete() async {
    try {
      await _firestore
          .collection('Employee')
          .doc('__firstUser__')
          .set({'exists': true});
    } catch (e) {
      print('Error marking first user setup: $e');
    }
  }
}
