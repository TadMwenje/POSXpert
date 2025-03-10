import 'package:flutter/material.dart';
import '../widgets/settings_style.dart';
import 'smart_dashboard_screen.dart'; // Import the dashboard screen
import 'orders_screen.dart'; // Import the orders screen

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            _buildSidebar(context), // Pass context to _buildSidebar
            const SizedBox(width: 20),
            Expanded(
              child: _buildMainContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 491,
      height: double.infinity,
      color: Color(0xFF363753),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildMenuItem('SETTINGS', Color(0xFF5CD2C6), context),
          _buildMenuItem('DASHBOARD', Colors.white, context),
          _buildMenuItem('ORDERS', Colors.white, context),
          _buildMenuItem('INVENTORY', Colors.white, context),
          _buildMenuItem('REPORTS', Colors.white, context),
          _buildMenuItem('LOGOUT', Colors.white, context),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, Color color, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: GestureDetector(
        onTap: () {
          if (title == 'DASHBOARD') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SmartDashboardScreen()),
            );
          } else if (title == 'ORDERS') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OrdersScreen()),
            );
          }
        },
        child: Text(
          title,
          style: SettingsStyles.menuTextStyle.copyWith(color: color),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFDFE3EE),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Information',
            style: SettingsStyles.headerTextStyle,
          ),
          const SizedBox(height: 20),
          _buildInputField('Business name'),
          _buildInputField('Address Line (optional)'),
          _buildInputField('Phone Number'),
          _buildInputField('VAT Number'),
          _buildInputField('TIN Number'),
          const SizedBox(height: 20),
          Text(
            'General Settings',
            style: SettingsStyles.headerTextStyle,
          ),
          const SizedBox(height: 20),
          _buildInputField('Currency'),
          _buildInputField('Language'),
          const SizedBox(height: 20),
          _buildToggle('Dark Mode', true), // Example toggle
          const SizedBox(height: 20),
          // Additional settings can be added here
        ],
      ),
    );
  }

  Widget _buildInputField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildToggle(String label, bool value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: SettingsStyles.toggleTextStyle),
        Switch(
          value: value,
          onChanged: (newValue) {},
        ),
      ],
    );
  }
}
