import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppSidebar extends StatefulWidget {
  final String currentScreen;

  const AppSidebar({Key? key, required this.currentScreen}) : super(key: key);

  @override
  _AppSidebarState createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('Employee')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _userRole = userDoc.data()?['role']?.toString().toLowerCase();
          });
        }
      } catch (e) {
        print('Error getting user role: $e');
      }
    }
  }

  bool _canAccess(String screen) {
    if (_userRole == 'admin') return true;

    switch (screen) {
      case 'dashboard':
        return _userRole == 'inventory' || _userRole == 'cashier';
      case 'orders':
        return _userRole == 'cashier';
      case 'inventory':
        return _userRole == 'inventory';
      case 'reports':
        return _userRole == 'inventory' || _userRole == 'admin';
      case 'settings':
      case 'users':
        return _userRole == 'admin';
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: Color(0xFF363753),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'POSXpert',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 30),
          Expanded(
            child: ListView(
              children: [
                if (_canAccess('dashboard'))
                  _buildNavItem('📊 Dashboard', '/dashboard',
                      widget.currentScreen == 'dashboard'),
                if (_canAccess('orders'))
                  _buildNavItem(
                      '📦 Orders', '/orders', widget.currentScreen == 'orders'),
                if (_canAccess('inventory'))
                  _buildNavItem('📋 Inventory', '/inventory',
                      widget.currentScreen == 'inventory'),
                if (_canAccess('reports'))
                  _buildNavItem('📈 Reports', '/reports',
                      widget.currentScreen == 'reports'),
                if (_canAccess('settings'))
                  _buildNavItem('⚙️ Settings', '/settings',
                      widget.currentScreen == 'settings'),
                if (_canAccess('users'))
                  _buildNavItem(
                      '👥 Users', '/useradd', widget.currentScreen == 'users'),
              ],
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.2)),
          _buildNavItem('👤 Logout', '/logout', false),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNavItem(String title, String route, bool isActive) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? Color(0xFF5CD2C6) : Colors.white.withOpacity(0.8),
          fontSize: 16,
        ),
      ),
      onTap: () {
        if (!isActive) {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }
}
