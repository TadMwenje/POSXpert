import 'package:flutter/material.dart';
import '../widgets/orders_style.dart';
import 'smart_dashboard_screen.dart';
import 'settings_screen.dart'; // Import the settings screen

class OrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
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
          _buildMenuItem('ORDERS', Color(0xFF5CD2C6), context),
          _buildMenuItem('DASHBOARD', Colors.white, context),
          _buildMenuItem('INVENTORY', Colors.white, context),
          _buildMenuItem('REPORTS', Colors.white, context),
          _buildMenuItem('SETTINGS', Colors.white, context),
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
          } else if (title == 'SETTINGS') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsScreen()),
            );
          }
        },
        child: Text(
          title,
          style: OrdersStyles.menuTextStyle.copyWith(color: color),
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
            'Search product by code, description or barcode',
            style: OrdersStyles.searchTextStyle,
          ),
          const SizedBox(height: 20),
          _buildProductGrid(),
          const SizedBox(height: 20),
          _buildSummarySection(),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return Expanded(
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        children: [
          _buildProductCard('Prada Handbag', '100.00'),
          _buildProductCard('Alexander Handbag', '150.00'),
          _buildProductCard('Gucci Handbag', '200.00'),
        ],
      ),
    );
  }

  Widget _buildProductCard(String productName, String price) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF5CD2C6),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            productName,
            style: OrdersStyles.itemTextStyle,
          ),
          Text(
            '\$$price',
            style: OrdersStyles.totalTextStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF363753),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Delivery Option',
            style: OrdersStyles.itemTextStyle.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            'Subtotal: 100.00',
            style: OrdersStyles.totalTextStyle.copyWith(color: Colors.white),
          ),
          Text(
            'Discount: 0.00',
            style: OrdersStyles.totalTextStyle.copyWith(color: Colors.white),
          ),
          Text(
            'Tax: 0.00',
            style: OrdersStyles.totalTextStyle.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: Text('PAY', style: TextStyle(fontSize: 24)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF5CD2C6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            ),
          ),
        ],
      ),
    );
  }
}
