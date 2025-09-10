import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../widgets/custom_text_styles1.dart';
import '../components/ai_assistant.dart';
import '../widgets/responsive_utils.dart';
import '../widgets/app_sidebar.dart';

class SmartDashboardScreen extends StatefulWidget {
  @override
  _SmartDashboardScreenState createState() => _SmartDashboardScreenState();
}

class _SmartDashboardScreenState extends State<SmartDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _ordersStream;
  late Stream<QuerySnapshot> _paymentsStream;
  late Stream<QuerySnapshot> _inventoryStream;

  double _monthlyRevenue = 0.0;
  double _todaySales = 0.0;
  int _lowStockItems = 0;
  int _newStockItems = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _recentOrders = [];
  Map<String, double> _categorySales = {};
  Map<String, dynamic>? _lowStockProduct;

  @override
  void initState() {
    super.initState();
    _ordersStream = _firestore
        .collection('Orders')
        .orderBy('created_at', descending: true)
        .limit(5)
        .snapshots();
    _paymentsStream = _firestore.collection('Payments').snapshots();
    _inventoryStream = _firestore.collection('Inventory').snapshots();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    _paymentsStream.listen((paymentsSnapshot) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final monthStart = DateTime(now.year, now.month, 1);

      double monthly = 0.0;
      double daily = 0.0;
      Map<String, double> categories = {};

      for (final doc in paymentsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final amount = (data['total_amount'] as num?)?.toDouble() ?? 0.0;
        final date = (data['payment_date'] as Timestamp).toDate();
        final items = List<Map<String, dynamic>>.from(data['items'] ?? []);

        monthly += amount;
        if (date.isAfter(today)) {
          daily += amount;
        }

        for (final item in items) {
          final category = item['category']?.toString() ?? 'Uncategorized';
          final price = (item['price'] as num?)?.toDouble() ?? 0.0;
          final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
          categories[category] =
              (categories[category] ?? 0) + (price * quantity);
        }
      }

      if (mounted) {
        setState(() {
          _monthlyRevenue = monthly;
          _todaySales = daily;
          _categorySales = categories;
        });
      }
    });

    _ordersStream.listen((ordersSnapshot) {
      List<Map<String, dynamic>> orders = [];
      for (final doc in ordersSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        orders.add({
          'id': doc.id,
          'total': (data['total_amount'] as num?)?.toDouble() ?? 0.0,
          'date': (data['created_at'] as Timestamp).toDate(),
          'status': data['status']?.toString() ?? 'completed',
        });
      }

      if (mounted) {
        setState(() {
          _recentOrders = orders;
        });
      }
    });

    _inventoryStream.listen((inventorySnapshot) {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);

      int lowStock = 0;
      int newStock = 0;
      Map<String, dynamic>? mostCritical;

      for (final doc in inventorySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final currentStock =
            int.tryParse(data['current_stock']?.toString() ?? '0') ?? 0;
        final minStock =
            int.tryParse(data['minimum_stock']?.toString() ?? '5') ?? 5;
        final updatedAt = (data['updated_at'] as Timestamp).toDate();

        if (currentStock <= minStock) {
          lowStock++;
          if (mostCritical == null ||
              currentStock < (mostCritical['current_stock'] ?? 0)) {
            mostCritical = {
              'name': data['product']?.toString() ?? 'Unknown Product',
              'current_stock': currentStock,
              'id': doc.id,
            };
          }
        }
        if (updatedAt.isAfter(monthStart)) newStock++;
      }

      if (mounted) {
        setState(() {
          _lowStockItems = lowStock;
          _newStockItems = newStock;
          _lowStockProduct = mostCritical;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/pos.png',
              height: ResponsiveUtils.responsiveValue(
                context,
                mobile: 30,
                tablet: 35,
                desktop: 40,
              ),
            ),
            SizedBox(width: ResponsiveUtils.isMobile(context) ? 8 : 10),
            Text(
              'Smart Dashboard',
              style: CustomTextStyles1.appBarTitle(context),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: ResponsiveUtils.isMobile(context)
            ? [
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: CustomSearchDelegate(),
                    );
                  },
                ),
              ]
            : [
                IconButton(
                  icon: Icon(Icons.notifications_outlined,
                      color: Color(0xFF5CD2C6)),
                  onPressed: () {},
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: ResponsiveUtils.responsiveValue(
                          context,
                          mobile: 14,
                          tablet: 15,
                          desktop: 16,
                        ),
                        backgroundImage:
                            NetworkImage('https://placehold.co/32'),
                      ),
                      SizedBox(width: 8),
                      Text('Admin User',
                          style: CustomTextStyles1.appBarAction(context)),
                      Icon(Icons.arrow_drop_down, color: Color(0xFF363753)),
                    ],
                  ),
                ),
              ],
        bottom: ResponsiveUtils.isMobile(context)
            ? null
            : PreferredSize(
                preferredSize: Size.fromHeight(60),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: '🔍 Search transactions/products...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              hintStyle: CustomTextStyles1.searchText(context),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Color(0xFF5CD2C6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AIAssistantDialog(),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.chat_bubble_outline,
                                  color: Colors.white,
                                  size: ResponsiveUtils.responsiveValue(
                                    context,
                                    mobile: 18,
                                    tablet: 19,
                                    desktop: 20,
                                  )),
                              SizedBox(width: 8),
                              Text('AI Assistant',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ResponsiveUtils.responsiveValue(
                                      context,
                                      mobile: 12,
                                      tablet: 13,
                                      desktop: 14,
                                    ),
                                    fontWeight: FontWeight.w600,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
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
          _isLoading
              ? _buildLoadingMetrics(context)
              : _buildMetricGrid(context),
          SizedBox(height: 16),
          _buildSalesPerformanceHeader(context),
          SizedBox(height: 16),
          _buildSalesChart(context),
          SizedBox(height: 16),
          _buildRecentOrders(context),
          SizedBox(height: 16),
          _buildTopCategories(context),
          SizedBox(height: 16),
          _buildRecommendations(context),
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
          child: AppSidebar(currentScreen: 'dashboard'),
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
                _isLoading
                    ? _buildLoadingMetrics(context)
                    : _buildMetricGrid(context),
                SizedBox(height: 24),
                _buildSalesPerformanceHeader(context),
                SizedBox(height: 16),
                _buildSalesChart(context),
                SizedBox(height: 24),
                _buildDataTables(context),
                SizedBox(height: 24),
                _buildRecommendations(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: ResponsiveUtils.isMobile(context) ? 2 : 4,
      crossAxisSpacing: ResponsiveUtils.responsiveValue(
        context,
        mobile: 12,
        tablet: 14,
        desktop: 16,
      ),
      mainAxisSpacing: ResponsiveUtils.responsiveValue(
        context,
        mobile: 12,
        tablet: 14,
        desktop: 16,
      ),
      childAspectRatio: ResponsiveUtils.isMobile(context) ? 1.1 : 1.2,
      children: [
        _buildMetricCard(
          context,
          title: 'MONTHLY REVENUE',
          value: '\$${_monthlyRevenue.toStringAsFixed(2)}',
          change: '↑ 18.2% from last month',
        ),
        _buildMetricCard(
          context,
          title: 'TODAY\'S SALES',
          value: '\$${_todaySales.toStringAsFixed(2)}',
          change: '↑ 13.5% from yesterday',
        ),
        _buildMetricCard(
          context,
          title: 'LOW STOCK',
          value: '$_lowStockItems',
          change: _lowStockItems > 0
              ? '$_lowStockItems items critical'
              : 'All good',
        ),
        _buildMetricCard(
          context,
          title: 'NEW STOCK',
          value: '$_newStockItems',
          change: 'This Month',
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String change,
  }) {
    return Container(
      padding: EdgeInsets.all(
        ResponsiveUtils.responsiveValue(
          context,
          mobile: 12,
          tablet: 14,
          desktop: 16,
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: CustomTextStyles1.metricTitle(context)),
          SizedBox(height: 8),
          Text(value, style: CustomTextStyles1.metricValue(context)),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.arrow_upward,
                color: Color(0xFF10B981),
                size: ResponsiveUtils.responsiveValue(
                  context,
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                ),
              ),
              SizedBox(width: 4),
              Text(change, style: CustomTextStyles1.metricChange(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalesPerformanceHeader(BuildContext context) {
    return Row(
      children: [
        Text(
          'SALES PERFORMANCE',
          style: CustomTextStyles1.sectionHeader(context),
        ),
        Spacer(),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFF5CD2C6)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.responsiveValue(
                      context,
                      mobile: 8,
                      tablet: 10,
                      desktop: 12,
                    ),
                    vertical: ResponsiveUtils.responsiveValue(
                      context,
                      mobile: 4,
                      tablet: 5,
                      desktop: 6,
                    )),
                child: Text(
                  'This month',
                  style: TextStyle(
                    color: Color(0xFF5CD2C6),
                    fontSize: ResponsiveUtils.responsiveValue(
                      context,
                      mobile: 12,
                      tablet: 13,
                      desktop: 14,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: ResponsiveUtils.responsiveValue(
                  context,
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                ),
                color: Color(0xFF5CD2C6),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.responsiveValue(
                      context,
                      mobile: 8,
                      tablet: 10,
                      desktop: 12,
                    ),
                    vertical: ResponsiveUtils.responsiveValue(
                      context,
                      mobile: 4,
                      tablet: 5,
                      desktop: 6,
                    )),
                child: Text(
                  'Export',
                  style: TextStyle(
                    color: Color(0xFF5CD2C6),
                    fontSize: ResponsiveUtils.responsiveValue(
                      context,
                      mobile: 12,
                      tablet: 13,
                      desktop: 14,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSalesChart(BuildContext context) {
    return Container(
      height: ResponsiveUtils.responsiveValue(
        context,
        mobile: 250,
        tablet: 280,
        desktop: 300,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SfCircularChart(
              legend: Legend(
                isVisible: true,
                overflowMode: LegendItemOverflowMode.wrap,
                position: ResponsiveUtils.isMobile(context)
                    ? LegendPosition.bottom
                    : LegendPosition.right,
              ),
              series: <CircularSeries>[
                PieSeries<ChartData, String>(
                  dataSource: [
                    ChartData('Card', _monthlyRevenue * 0.7, '70%'),
                    ChartData('Cash', _monthlyRevenue * 0.2, '20%'),
                    ChartData('Giftcard', _monthlyRevenue * 0.1, '10%'),
                  ],
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y,
                  dataLabelMapper: (ChartData data, _) => data.text,
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.inside,
                  ),
                )
              ],
            ),
    );
  }

  Widget _buildDataTables(BuildContext context) {
    if (ResponsiveUtils.isMobile(context)) {
      return Column(
        children: [
          _buildRecentOrders(context),
          SizedBox(height: 16),
          _buildTopCategories(context),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _buildRecentOrders(context),
          ),
          SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: _buildTopCategories(context),
          ),
        ],
      );
    }
  }

  Widget _buildRecentOrders(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECENT ORDERS',
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
                    tablet: 13,
                    desktop: 14,
                  ),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(
            ResponsiveUtils.responsiveValue(
              context,
              mobile: 12,
              tablet: 14,
              desktop: 16,
            ),
          ),
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
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
                          'Order ID',
                          style: CustomTextStyles1.tableHeader(context),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Amount',
                          style: CustomTextStyles1.tableHeader(context),
                        ),
                      ),
                      if (!ResponsiveUtils.isMobile(context))
                        DataColumn(
                          label: Text(
                            'Date',
                            style: CustomTextStyles1.tableHeader(context),
                          ),
                        ),
                      DataColumn(
                        label: Text(
                          'Status',
                          style: CustomTextStyles1.tableHeader(context),
                        ),
                      ),
                    ],
                    rows: _recentOrders.map((order) {
                      final date = order['date'] as DateTime;
                      return DataRow(cells: [
                        DataCell(Text(
                          order['id'].toString().substring(0, 8),
                          style: CustomTextStyles1.tableCell(context),
                        )),
                        DataCell(Text(
                          '\$${order['total'].toStringAsFixed(2)}',
                          style: CustomTextStyles1.tableCell(context),
                        )),
                        if (!ResponsiveUtils.isMobile(context))
                          DataCell(Text(
                            '${date.day}/${date.month}/${date.year}',
                            style: CustomTextStyles1.tableCell(context),
                          )),
                        DataCell(Text(
                          order['status'],
                          style: CustomTextStyles1.tableCell(context).copyWith(
                            color: _getStatusColor(order['status']),
                          ),
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildTopCategories(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TOP CATEGORIES',
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
                    tablet: 13,
                    desktop: 14,
                  ),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(
            ResponsiveUtils.responsiveValue(
              context,
              mobile: 12,
              tablet: 14,
              desktop: 16,
            ),
          ),
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : DataTable(
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
                        'Category',
                        style: CustomTextStyles1.tableHeader(context),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Sales',
                        style: CustomTextStyles1.tableHeader(context),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        '%',
                        style: CustomTextStyles1.tableHeader(context),
                      ),
                    ),
                  ],
                  rows: (_categorySales.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value)))
                      .take(3)
                      .map((entry) {
                    final percentage = (entry.value / _monthlyRevenue * 100)
                        .toStringAsFixed(1);
                    return DataRow(cells: [
                      DataCell(Text(
                        entry.key,
                        style: CustomTextStyles1.tableCell(context),
                      )),
                      DataCell(Text(
                        '\$${entry.value.toStringAsFixed(2)}',
                        style: CustomTextStyles1.tableCell(context),
                      )),
                      DataCell(Text(
                        '$percentage%',
                        style: CustomTextStyles1.tableCell(context),
                      )),
                    ]);
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildRecommendations(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECOMMENDATIONS',
          style: CustomTextStyles1.sectionHeader(context),
        ),
        SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(
            ResponsiveUtils.responsiveValue(
              context,
              mobile: 12,
              tablet: 14,
              desktop: 16,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _lowStockItems > 0
                          ? Color(0xFFFEE2E2)
                          : Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Restock Alert',
                      style: TextStyle(
                        color: _lowStockItems > 0
                            ? Color(0xFFB91C1C)
                            : Color(0xFF065F46),
                        fontSize: ResponsiveUtils.responsiveValue(
                          context,
                          mobile: 12,
                          tablet: 12,
                          desktop: 12,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    _lowStockItems > 0 ? 'HIGH' : 'LOW',
                    style: TextStyle(
                      color: _lowStockItems > 0
                          ? Color(0xFFB91C1C)
                          : Color(0xFF065F46),
                      fontSize: ResponsiveUtils.responsiveValue(
                        context,
                        mobile: 12,
                        tablet: 12,
                        desktop: 12,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                _lowStockItems > 0
                    ? '${_lowStockProduct?['name'] ?? 'A product'} is running low (${_lowStockProduct?['current_stock'] ?? 0} left). Based on sales trends, you should reorder soon to avoid stock outs.'
                    : 'All inventory items are well stocked. No immediate reordering needed.',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: ResponsiveUtils.responsiveValue(
                    context,
                    mobile: 13,
                    tablet: 14,
                    desktop: 14,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton(
                    onPressed: _lowStockItems > 0
                        ? () {
                            Navigator.pushNamed(
                              context,
                              '/inventory/edit',
                              arguments: {
                                'productId': _lowStockProduct?['id'],
                              },
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF5CD2C6),
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.responsiveValue(
                          context,
                          mobile: 12,
                          tablet: 14,
                          desktop: 16,
                        ),
                        vertical: ResponsiveUtils.responsiveValue(
                          context,
                          mobile: 8,
                          tablet: 8,
                          desktop: 8,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      'Reorder',
                      style: CustomTextStyles1.buttonText(context),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/inventory');
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF5CD2C6)),
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.responsiveValue(
                          context,
                          mobile: 12,
                          tablet: 14,
                          desktop: 16,
                        ),
                        vertical: ResponsiveUtils.responsiveValue(
                          context,
                          mobile: 8,
                          tablet: 8,
                          desktop: 8,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      'View Details',
                      style: TextStyle(
                        color: Color(0xFF5CD2C6),
                        fontSize: ResponsiveUtils.responsiveValue(
                          context,
                          mobile: 12,
                          tablet: 13,
                          desktop: 14,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingMetrics(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: ResponsiveUtils.isMobile(context) ? 2 : 4,
      crossAxisSpacing: ResponsiveUtils.responsiveValue(
        context,
        mobile: 12,
        tablet: 14,
        desktop: 16,
      ),
      mainAxisSpacing: ResponsiveUtils.responsiveValue(
        context,
        mobile: 12,
        tablet: 14,
        desktop: 16,
      ),
      childAspectRatio: ResponsiveUtils.isMobile(context) ? 1.1 : 1.2,
      children: List.generate(
        4,
        (index) => Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
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
        )),
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
            'DASHBOARD',
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
        )),
        _buildNavItem(context, '📊 SALES PERFORMANCE', '/dashboard', true),
        _buildNavItem(context, '📦 ORDERS', '/orders', false),
        _buildNavItem(context, '📋 INVENTORY', '/inventory', false),
        _buildNavItem(context, '📈 REPORTS', '/reports', false),
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
          Navigator.pushNamed(context, route);
        }
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Color(0xFF10B981);
      case 'pending':
        return Color(0xFFF59E0B);
      case 'cancelled':
        return Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }
}

class ChartData {
  final String x;
  final double y;
  final String text;

  ChartData(this.x, this.y, this.text);
}

class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Implement your search results here
    return Center(
      child: Text('Search results for: $query'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Implement your search suggestions here
    return Center(
      child: Text('Search suggestions'),
    );
  }
}
