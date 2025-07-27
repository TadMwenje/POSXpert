import 'package:flutter/material.dart';
import '../widgets/features_style.dart';

class FeaturesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Current Plan: Freemium',
              style: FeaturesStyles.currentPlanStyle),
          const SizedBox(height: 40),
          Text('Sales Features', style: FeaturesStyles.sectionHeaderStyle),
          const SizedBox(height: 20),
          _buildFeatureCard(
            'Multi-Payment Methods',
            'Accept cash, credit cards, mobile payments, and more in a single transaction',
            true,
            'Freemium',
          ),
          const SizedBox(height: 20),
          Text('Inventory Features', style: FeaturesStyles.sectionHeaderStyle),
          const SizedBox(height: 20),
          _buildFeatureCard(
            'Basic Inventory',
            'Track product quantities and receive low stock alerts',
            true,
            'Freemium',
          ),
          const SizedBox(height: 20),
          _buildFeatureCard(
            'Advanced Inventory',
            'Track inventory across multiple locations with transfer management',
            false,
            'Premium',
          ),
          const SizedBox(height: 20),
          Text('Customer Features', style: FeaturesStyles.sectionHeaderStyle),
          const SizedBox(height: 20),
          _buildFeatureCard(
            'Customer Database',
            'Store basic customer information and purchase history',
            true,
            'Freemium',
          ),
          const SizedBox(height: 20),
          _buildFeatureCard(
            'Customer Segmentation',
            'Group customers for targeted marketing and promotions',
            false,
            'Premium',
          ),
          const SizedBox(height: 20),
          Text('Reporting Features', style: FeaturesStyles.sectionHeaderStyle),
          const SizedBox(height: 20),
          _buildFeatureCard(
            'Basic Sales Reports',
            'View daily, weekly, and monthly sales summaries',
            true,
            'Freemium',
          ),
          const SizedBox(height: 20),
          _buildFeatureCard(
            'Scheduled Reports',
            'Automatically generate and email reports on schedule',
            false,
            'Premium',
          ),
          const SizedBox(height: 40),
          Center(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                padding:
                    const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text('Upgrade to Premium',
                  style: FeaturesStyles.upgradeButtonStyle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
      String title, String description, bool isActive, String plan) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF363753), width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: FeaturesStyles.featureTitleStyle),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF5CD2C6)
                      : const Color(0xFFEE1D20),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  isActive ? 'Active' : 'Inactive',
                  style: FeaturesStyles.statusTextStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(description, style: FeaturesStyles.featureDescriptionStyle),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.grey),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  color: plan == 'Premium'
                      ? const Color(0x7AFFC014)
                      : const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(plan, style: FeaturesStyles.planTextStyle),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
