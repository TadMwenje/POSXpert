import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserData with ChangeNotifier {
  final String uid;
  final String email;
  final String firstName;
  final String? lastName;
  final String phone;
  final String role;
  final String username;
  final bool isActive;
  final DateTime createdAt;

  UserData({
    required this.uid,
    required this.email,
    required this.firstName,
    this.lastName,
    required this.phone,
    required this.role,
    required this.username,
    required this.isActive,
    required this.createdAt,
  });
  factory UserData.placeholder() {
    return UserData(
      uid: '',
      email: '',
      firstName: '',
      lastName: '',
      phone: '',
      role: 'cashier',
      username: '',
      isActive: false,
      createdAt: DateTime.now(),
    );
  }

  factory UserData.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserData(
      uid: doc.id,
      email: data['email'] ?? '',
      firstName: data['f_name'] ?? '',
      lastName: data['l_name'],
      phone: data['phone'] ?? '',
      role: (data['role']?.toString().toLowerCase()) ?? 'cashier',
      username: data['username'] ?? '',
      isActive: data['state'] == 'active',
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isManager => role == 'manager';
  bool get isCashier => role == 'cashier';
  bool get isInventoryManager => role == 'inventory';

  bool hasAccessTo(String screen) {
    switch (role) {
      case 'admin':
        return true;
      case 'manager':
        return ['dashboard', 'orders', 'inventory', 'reports'].contains(screen);
      case 'cashier':
        return ['orders'].contains(screen);
      case 'inventory':
        return ['inventory'].contains(screen);
      default:
        return false;
    }
  }
}
