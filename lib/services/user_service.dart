import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserService {
  static const String _storageKey = 'users_data';

  static Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_storageKey) ?? '[]';
      return List<Map<String, dynamic>>.from(json.decode(usersJson));
    } catch (e) {
      print('Error reading users: $e');
      return [];
    }
  }

  static Future<void> addUser(Map<String, dynamic> user) async {
    try {
      final users = await getUsers();
      if (users.any((u) => u['email'] == user['email'])) {
        throw Exception('Email already exists');
      }
      users.add(user);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, json.encode(users));
    } catch (e) {
      print('Error adding user: $e');
      rethrow;
    }
  }

  static Future<bool> validateUser(String email, String password) async {
    final users = await getUsers();
    return users
        .any((user) => user['email'] == email && user['password'] == password);
  }
}
