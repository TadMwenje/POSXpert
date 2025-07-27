// widgets/app_sidebar.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/smart_dashboard_screen.dart';
import '../screens/inventory_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/login_screen.dart';
import 'inventory_style.dart';

class AppSidebar extends StatelessWidget {
  final String currentScreen;

  const AppSidebar({Key? key, required this.currentScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: const Color(0xFF363753),
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildMenuItem(
            context,
            '🏠 Dashboard',
            'dashboard',
            SmartDashboardScreen(),
          ),
          _buildMenuItem(
            context,
            '📄 Orders',
            'orders',
            OrdersScreen(),
          ),
          _buildMenuItem(
            context,
            '📦 Inventory',
            'inventory',
            const InventoryScreen(),
          ),
          _buildMenuItem(
            context,
            '📊 Reports',
            'reports',
            ReportsScreen(),
          ),
          _buildMenuItem(
            context,
            '⚙️ Settings',
            'settings',
            SettingsScreen(),
          ),
          const Spacer(),
          _buildLogoutButton(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    String screenName,
    Widget screen,
  ) {
    final isActive = currentScreen == screenName;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        child: Text(
          title,
          style: InventoryStyles.menuTextStyle.copyWith(
            color: isActive ? const Color(0xFF5CD2C6) : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: InkWell(
        onTap: () async {
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Confirm Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );

          if (shouldLogout == true) {
            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          }
        },
        child: Text(
          'LOGOUT',
          style: InventoryStyles.menuTextStyle.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
