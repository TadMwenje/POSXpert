// reports_screen.dart
import 'package:flutter/material.dart';
import '../widgets/custom_text_styles1.dart';
import '../widgets/responsive_utils.dart';
import 'smart_dashboard_screen.dart';
import 'settings_screen.dart';
import 'inventory_screen.dart';
import 'orders_screen.dart';

class ReportsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: ResponsiveUtils.isMobile(context)
          ? AppBar(
              title: Text(
                'Reports',
                style: CustomTextStyles1.appBarTitle(context),
              ),
              backgroundColor: Colors.white,
              elevation: 1,
            )
          : null,
      drawer: ResponsiveUtils.isMobile(context)
          ? Drawer(
              child: _buildSidebar(context),
            )
          : null,
      body: ResponsiveUtils.isMobile(context)
          ? _buildMobileLayout(context)
          : _buildDesktopLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeaderSection(context),
          SizedBox(height: 16),
          _buildReportTypeSection(context),
          SizedBox(height: 16),
          _buildActionButtons(context),
          SizedBox(height: 24),
          _buildTopSellingProducts(context),
          SizedBox(height: 24),
          _buildAllTransactions(context),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        Container(
          width: ResponsiveUtils.responsiveValue(
            context,
            mobile: 0,
            tablet: 200,
            desktop: 240,
          ),
          color: Color(0xFF363753),
          child: _buildSidebar(context),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(
              ResponsiveUtils.responsiveValue(
                context,
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(context),
                SizedBox(height: 24),
                _buildReportTypeSection(context),
                SizedBox(height: 16),
                _buildActionButtons(context),
                SizedBox(height: 24),
                _buildTopSellingProducts(context),
                SizedBox(height: 24),
                _buildAllTransactions(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('REPORTS', style: CustomTextStyles1.sectionHeader(context)),
        Text(
          'Last Updated: Today, 8:30 AM',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: ResponsiveUtils.responsiveValue(
              context,
              mobile: 12,
              tablet: 14,
              desktop: 16,
            ),
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildReportTypeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Report Type', style: CustomTextStyles1.sectionHeader(context)),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.responsiveValue(
              context,
              mobile: 12,
              tablet: 16,
              desktop: 20,
            ),
            vertical: ResponsiveUtils.responsiveValue(
              context,
              mobile: 14,
              tablet: 16,
              desktop: 18,
            ),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Color(0xFFE5E7EB)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select report',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: ResponsiveUtils.responsiveValue(
                    context,
                    mobile: 14,
                    tablet: 16,
                    desktop: 18,
                  ),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: Color(0xFF6B7280),
                size: ResponsiveUtils.responsiveValue(
                  context,
                  mobile: 24,
                  tablet: 28,
                  desktop: 32,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return isMobile
        ? Column(
            children: [
              _buildActionButton(
                context,
                'Generate Report',
                Color(0xFF363753),
                Colors.white,
              ),
              SizedBox(height: 12),
              _buildActionButton(
                context,
                'Reset Filters',
                Colors.white,
                Color(0xFF363753),
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  'Generate Report',
                  Color(0xFF363753),
                  Colors.white,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  context,
                  'Reset Filters',
                  Colors.white,
                  Color(0xFF363753),
                ),
              ),
            ],
          );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    Color backgroundColor,
    Color textColor,
  ) {
    return Container(
      height: ResponsiveUtils.responsiveValue(
        context,
        mobile: 48,
        tablet: 52,
        desktop: 56,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: textColor == Color(0xFF363753)
              ? Color(0xFF363753)
              : Colors.transparent,
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: CustomTextStyles1.buttonText(context).copyWith(
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildTopSellingProducts(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Selling Products',
          style: CustomTextStyles1.sectionHeader(context),
        ),
        SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(
            ResponsiveUtils.responsiveValue(
              context,
              mobile: 12,
              tablet: 16,
              desktop: 20,
            ),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            scrollDirection: ResponsiveUtils.isMobile(context)
                ? Axis.horizontal
                : Axis.vertical,
            child: DataTable(
              columnSpacing: ResponsiveUtils.responsiveValue(
                context,
                mobile: 12,
                tablet: 16,
                desktop: 24,
              ),
              dataRowHeight: ResponsiveUtils.responsiveValue(
                context,
                mobile: 48,
                tablet: 52,
                desktop: 56,
              ),
              columns: [
                DataColumn(
                  label: Text(
                    'Product',
                    style: CustomTextStyles1.tableHeader(context),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Category',
                    style: CustomTextStyles1.tableHeader(context),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Quantity',
                    style: CustomTextStyles1.tableHeader(context),
                    textAlign: TextAlign.center,
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Revenue',
                    style: CustomTextStyles1.tableHeader(context),
                    textAlign: TextAlign.end,
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Profit',
                    style: CustomTextStyles1.tableHeader(context),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
              rows: [
                _buildProductRow(
                  context,
                  'Premium Coffee Blend',
                  'Beverages',
                  '120',
                  '\$1,200',
                  '\$800',
                ),
                _buildProductRow(
                  context,
                  'Organic Tea',
                  'Beverages',
                  '85',
                  '\$850',
                  '\$600',
                ),
                _buildProductRow(
                  context,
                  'Chocolate Croissant',
                  'Pastry',
                  '65',
                  '\$650',
                  '\$450',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  DataRow _buildProductRow(
    BuildContext context,
    String product,
    String category,
    String quantity,
    String revenue,
    String profit,
  ) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            product,
            style: CustomTextStyles1.tableCell(context),
          ),
        ),
        DataCell(
          Text(
            category,
            style: CustomTextStyles1.tableCell(context),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              quantity,
              style: CustomTextStyles1.tableCell(context),
            ),
          ),
        ),
        DataCell(
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              revenue,
              style: CustomTextStyles1.tableCell(context),
            ),
          ),
        ),
        DataCell(
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              profit,
              style: CustomTextStyles1.tableCell(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllTransactions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ALL TRANSACTIONS',
              style: CustomTextStyles1.sectionHeader(context),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'VIEW ALL',
                style: TextStyle(
                  color: Color(0xFF5CD2C6),
                  fontSize: ResponsiveUtils.responsiveValue(
                    context,
                    mobile: 12,
                    tablet: 14,
                    desktop: 16,
                  ),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(
            ResponsiveUtils.responsiveValue(
              context,
              mobile: 12,
              tablet: 16,
              desktop: 20,
            ),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            scrollDirection: ResponsiveUtils.isMobile(context)
                ? Axis.horizontal
                : Axis.vertical,
            child: DataTable(
              columnSpacing: ResponsiveUtils.responsiveValue(
                context,
                mobile: 12,
                tablet: 16,
                desktop: 24,
              ),
              dataRowHeight: ResponsiveUtils.responsiveValue(
                context,
                mobile: 48,
                tablet: 52,
                desktop: 56,
              ),
              columns: [
                DataColumn(
                  label: Text(
                    'Date',
                    style: CustomTextStyles1.tableHeader(context),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Transaction',
                    style: CustomTextStyles1.tableHeader(context),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Customer ID',
                    style: CustomTextStyles1.tableHeader(context),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Amount',
                    style: CustomTextStyles1.tableHeader(context),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Total VAT',
                    style: CustomTextStyles1.tableHeader(context),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Payment Method',
                    style: CustomTextStyles1.tableHeader(context),
                  ),
                ),
              ],
              rows: [
                _buildTransactionRow(
                  context,
                  '2025-10-01 10:15:00',
                  'TXN1001',
                  'C001',
                  '\$500',
                  '\$23.46',
                  'Cash',
                ),
                _buildTransactionRow(
                  context,
                  '2025-10-01 11:30:00',
                  'TXN1002',
                  'C002',
                  '\$750',
                  '\$35.75',
                  'Credit Card',
                ),
                _buildTransactionRow(
                  context,
                  '2025-10-01 14:45:00',
                  'TXN1003',
                  'C003',
                  '\$2,570',
                  '\$80.34',
                  'Cash',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  DataRow _buildTransactionRow(
    BuildContext context,
    String date,
    String transaction,
    String customerId,
    String amount,
    String vat,
    String paymentMethod,
  ) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            date,
            style: CustomTextStyles1.tableCell(context),
          ),
        ),
        DataCell(
          Text(
            transaction,
            style: CustomTextStyles1.tableCell(context),
          ),
        ),
        DataCell(
          Text(
            customerId,
            style: CustomTextStyles1.tableCell(context),
          ),
        ),
        DataCell(
          Text(
            amount,
            style: CustomTextStyles1.tableCell(context),
          ),
        ),
        DataCell(
          Text(
            vat,
            style: CustomTextStyles1.tableCell(context),
          ),
        ),
        DataCell(
          Text(
            paymentMethod,
            style: CustomTextStyles1.tableCell(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
          height: ResponsiveUtils.responsiveValue(
            context,
            mobile: 20,
            tablet: 30,
            desktop: 40,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.responsiveValue(
              context,
              mobile: 12,
              tablet: 14,
              desktop: 16,
            ),
          ),
          child: Text(
            'REPORTS',
            style: TextStyle(
              color: Color(0xFF5CD2C6),
              fontSize: ResponsiveUtils.responsiveValue(
                context,
                mobile: 18,
                tablet: 20,
                desktop: 24,
              ),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: ResponsiveUtils.responsiveValue(
            context,
            mobile: 20,
            tablet: 30,
            desktop: 40,
          ),
        ),
        _buildNavItem(context, '📊 SALES PERFORMANCE', '/dashboard', false),
        _buildNavItem(context, '📦 ORDERS', '/orders', false),
        _buildNavItem(context, '📋 INVENTORY', '/inventory', false),
        _buildNavItem(context, '📈 REPORTS', '/reports', true),
        _buildNavItem(context, '⚙️ SETTINGS', '/settings', false),
        Spacer(),
        Divider(color: Colors.white.withOpacity(0.2)),
        _buildNavItem(context, '👤 LOGOUT', '/logout', false),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String title,
    String route,
    bool isActive,
  ) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? Color(0xFF5CD2C6) : Colors.white.withOpacity(0.8),
          fontSize: ResponsiveUtils.responsiveValue(
            context,
            mobile: 14,
            tablet: 15,
            desktop: 16,
          ),
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () {
        if (!isActive) {
          if (route == '/dashboard') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SmartDashboardScreen()),
            );
          } else if (route == '/orders') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OrdersScreen()),
            );
          } else if (route == '/settings') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SettingsScreen()),
            );
          } else if (route == '/inventory') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => InventoryScreen()),
            );
          }
        }
      },
    );
  }
}
