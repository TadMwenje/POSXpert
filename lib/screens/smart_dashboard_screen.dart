import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_text_styles1.dart';

class SmartDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Dashboard', style: CustomTextStyles1.dashboardTitle),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('Sales', style: CustomTextStyles1.navBarItem),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(
                  context, '/orders'); // Navigate to OrdersScreen
            },
            child: Text('Orders', style: CustomTextStyles1.navBarItem),
          ),
          TextButton(
            onPressed: () {},
            child: Text('Inventory', style: CustomTextStyles1.navBarItem),
          ),
          TextButton(
            onPressed: () {},
            child: Text('Reports', style: CustomTextStyles1.navBarItem),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(
                  context, '/settings'); // Navigate to SettingsScreen
            },
            child: Text('Settings', style: CustomTextStyles1.navBarItem),
          ),
          TextButton(
            onPressed: () {},
            child: Text('Help & Support', style: CustomTextStyles1.navBarItem),
          ),
          TextButton(
            onPressed: () {},
            child: Text('Logout', style: CustomTextStyles1.navBarItem),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Total Revenue Card
              buildCard(
                title: 'TOTAL REVENUE',
                value: '\$175K',
                percentageChange: '10.5%',
                changeDescription: 'From Last day',
              ),
              const SizedBox(height: 20),

              // Customer Growth Card
              buildCard(
                title: 'CUSTOMER GROWTH',
                value: '110',
                percentageChange: '0.5%',
                changeDescription: 'From Last day',
              ),
              const SizedBox(height: 20),

              // Sales NPS Score Card
              buildCard(
                title: 'SALES NPS SCORE',
                value: '82%',
                percentageChange: 'Last month: 75%',
              ),
              const SizedBox(height: 20),

              // Sales Prediction Card
              buildCard(
                title: 'SALES PREDICTION',
                value: '20%',
                percentageChange: 'Last month: 15%',
              ),
              const SizedBox(height: 20),

              // Return Rate Card
              buildCard(
                title: 'RETURN RATE',
                value: '2%',
                percentageChange: 'Last month: 3%',
              ),
              const SizedBox(height: 20),

              // Customer Satisfaction Card
              buildCard(
                title: 'CUSTOMER SATISFACTION',
                value: '96%',
                percentageChange: 'Last month: 94%',
              ),
              const SizedBox(height: 20),

              // Sales By Day Graph Placeholder
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Color(0xFFDFE3EE),
                ),
                child: Center(child: Text('Sales By Day Graph Placeholder')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCard({
    required String title,
    required String value,
    String? percentageChange,
    String? changeDescription,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF363753),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: CustomTextStyles1.cardTitle),
          const SizedBox(height: 10),
          Text(value, style: CustomTextStyles1.cardValue),
          if (percentageChange != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(percentageChange, style: CustomTextStyles1.cardPercentage),
                if (changeDescription != null)
                  Text(changeDescription,
                      style: CustomTextStyles1.cardDescription),
              ],
            ),
        ],
      ),
    );
  }
}
