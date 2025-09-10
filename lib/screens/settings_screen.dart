import 'package:flutter/material.dart';
import '../widgets/settings_style.dart';
import '../widgets/app_sidebar.dart';
import 'reports_screen.dart';
import 'smart_dashboard_screen.dart';
import 'orders_screen.dart';
import 'inventory_screen.dart';
import 'tax_screen.dart';
import 'users_screen.dart';
import 'features_screen.dart';
import 'receipt_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedTab = 'General';
  final TextEditingController _storeNameController =
      TextEditingController(text: 'My POS Store');
  final TextEditingController _phoneController =
      TextEditingController(text: '+263 712345678');
  final TextEditingController _addressController =
      TextEditingController(text: '123 Main St, Harare, Zimbabwe');
  final TextEditingController _emailController =
      TextEditingController(text: 'example@email.com');
  String _currency = 'USD';
  String _currencyPosition = 'Left \$100';
  String _decimalSeparator = 'Point(.)';
  String _thousandSeparator = 'Comma (,)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF5F5F5),
        child: Row(
          children: [
            AppSidebar(currentScreen: 'settings'), // Pass 'settings' here
            Expanded(
              child: _buildMainContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabBar(),
            const SizedBox(height: 20),
            if (_selectedTab == 'General') _buildGeneralSettings(),
            if (_selectedTab == 'Tax') _buildTaxSettings(),
            if (_selectedTab == 'Receipt') _buildReceiptSettings(),
            if (_selectedTab == 'Users') _buildUserSettings(),
            if (_selectedTab == 'Backup') _buildBackupSettings(),
            if (_selectedTab == 'Features') _buildFeatureSettings(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTabButton('General'),
          _buildTabButton('Tax'),
          _buildTabButton('Receipt'),
          _buildTabButton('Users'),
          _buildTabButton('Backup'),
          _buildTabButton('Features'),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title) {
    return TextButton(
      onPressed: () {
        setState(() {
          _selectedTab = title;
        });
      },
      child: Text(
        title,
        style: SettingsStyles.tabTextStyle.copyWith(
          color: _selectedTab == title ? Colors.black : Colors.grey,
          fontWeight:
              _selectedTab == title ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Store Information', style: SettingsStyles.sectionHeaderStyle),
          const SizedBox(height: 20),
          _buildStoreInfoTable(),
          const SizedBox(height: 40),
          Text('Currency Settings', style: SettingsStyles.sectionHeaderStyle),
          const SizedBox(height: 20),
          _buildCurrencySettingsTable(),
          const SizedBox(height: 40),
          Center(
            child: ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF363753),
                padding:
                    const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child:
                  Text('Save Settings', style: SettingsStyles.saveButtonStyle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreInfoTable() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Text('Store Name', style: SettingsStyles.tableLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: TextField(
                controller: _storeNameController,
                style: SettingsStyles.tableValueStyle,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                ),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child:
                  Text('Phone Number', style: SettingsStyles.tableLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: TextField(
                controller: _phoneController,
                style: SettingsStyles.tableValueStyle,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                ),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Text('Address', style: SettingsStyles.tableLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: TextField(
                controller: _addressController,
                style: SettingsStyles.tableValueStyle,
                maxLines: 2,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                ),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child:
                  Text('Email Address', style: SettingsStyles.tableLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: TextField(
                controller: _emailController,
                style: SettingsStyles.tableValueStyle,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrencySettingsTable() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Text('Currency', style: SettingsStyles.tableLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: DropdownButtonFormField<String>(
                value: _currency,
                items: ['USD', 'ZAR', 'EUR', 'GBP'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: SettingsStyles.tableValueStyle),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _currency = newValue!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                ),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Text('Currency Position',
                  style: SettingsStyles.tableLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: DropdownButtonFormField<String>(
                value: _currencyPosition,
                items: [
                  'Left \$100',
                  'Right 100\$',
                  'Left 100\$',
                  'Right \$100'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: SettingsStyles.tableValueStyle),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _currencyPosition = newValue!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                ),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Text('Decimal Separator',
                  style: SettingsStyles.tableLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: DropdownButtonFormField<String>(
                value: _decimalSeparator,
                items: ['Point(.)', 'Comma (,)'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: SettingsStyles.tableValueStyle),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _decimalSeparator = newValue!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                ),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Text('Thousand Separator',
                  style: SettingsStyles.tableLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: DropdownButtonFormField<String>(
                value: _thousandSeparator,
                items:
                    ['Comma (,)', 'Point(.)', 'Space ( )'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: SettingsStyles.tableValueStyle),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _thousandSeparator = newValue!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTaxSettings() {
    return TaxScreen();
  }

  Widget _buildReceiptSettings() {
    return ReceiptScreen();
  }

  Widget _buildUserSettings() {
    return UsersScreen();
  }

  Widget _buildBackupSettings() {
    return Center(
        child:
            Text('Backup Settings', style: SettingsStyles.sectionHeaderStyle));
  }

  Widget _buildFeatureSettings() {
    return FeaturesScreen();
  }

  void _saveSettings() {
    // Implement save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Settings saved successfully')),
    );
  }
}
