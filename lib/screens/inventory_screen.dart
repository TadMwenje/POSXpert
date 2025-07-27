import 'package:flutter/material.dart';
import '../services/inventory_service.dart';
import 'inventory_view.dart';
import 'inventory_edit.dart';
import 'inventory_product_screen.dart';
import '../widgets/custom_text_styles1.dart';
import '../widgets/responsive_utils.dart';
import 'barcode_scanner_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late Future<List<Map<String, dynamic>>> _inventoryFuture;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredInventory = [];

  @override
  void initState() {
    super.initState();
    _loadInventory();
    _searchController.addListener(_filterInventory);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadInventory() {
    setState(() {
      _inventoryFuture = InventoryService.getInventory().then((inventory) {
        _filteredInventory = inventory;
        return inventory;
      });
    });
  }

  void _filterInventory() {
    final query = _searchController.text.toLowerCase();
    _inventoryFuture.then((inventory) {
      setState(() {
        _filteredInventory = inventory.where((item) {
          return item['product'].toString().toLowerCase().contains(query) ||
              item['code'].toString().toLowerCase().contains(query) ||
              item['barcode'].toString().toLowerCase().contains(query);
        }).toList();
      });
    });
  }

  Future<void> _startBarcodeScan() async {
    final scanOption = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Scan Barcode',
            style: CustomTextStyles1.sectionHeader(context)),
        content: Text('Choose scanning method:',
            style: CustomTextStyles1.tableCell(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'camera'),
            child: Text('Camera',
                style: CustomTextStyles1.buttonText(context)
                    .copyWith(color: Color(0xFF5CD2C6))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'usb'),
            child: Text('USB Scanner',
                style: CustomTextStyles1.buttonText(context)
                    .copyWith(color: Color(0xFF5CD2C6))),
          ),
        ],
      ),
    );

    if (scanOption == null) return;

    String? barcode;

    if (scanOption == 'camera') {
      barcode = await _scanWithCamera();
    } else if (scanOption == 'usb') {
      barcode = await _scanWithUsb();
    }

    if (barcode != null && barcode.isNotEmpty && mounted) {
      _handleScannedBarcode(barcode);
    }
  }

  Future<String?> _scanWithCamera() async {
    try {
      final barcode = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => BarcodeScannerScreen(
            onScan: (barcode) => Navigator.pop(context, barcode),
            showCamera: true,
          ),
        ),
      );
      return barcode;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Camera Error: ${e.toString()}',
                  style: CustomTextStyles1.tableCell(context))),
        );
      }
      return null;
    }
  }

  Future<void> _handleScannedBarcode(String barcode) async {
    if (!mounted) return;

    try {
      final inventory = await InventoryService.getInventory();
      final existingProduct = inventory
          .where((product) => product['barcode'].toString() == barcode)
          .toList();

      if (existingProduct.isNotEmpty && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;

          final action = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Product Found',
                  style: CustomTextStyles1.sectionHeader(context)),
              content: Text(
                'Found: ${existingProduct.first['product']}\nCurrent stock: ${existingProduct.first['current_stock']}',
                style: CustomTextStyles1.tableCell(context),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, 'view'),
                  child: Text('View Details',
                      style: CustomTextStyles1.buttonText(context)
                          .copyWith(color: Color(0xFF5CD2C6))),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, 'update'),
                  child: Text('Update Quantity',
                      style: CustomTextStyles1.buttonText(context)
                          .copyWith(color: Color(0xFF5CD2C6))),
                ),
              ],
            ),
          );

          if (action == 'view' && mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InventoryViewScreen(
                  productData: Map<String, dynamic>.from(existingProduct.first),
                ),
              ),
            );
          } else if (action == 'update' && mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InventoryEditScreen(
                  productData: Map<String, dynamic>.from(existingProduct.first),
                ),
              ),
            ).then((_) => _loadInventory());
          }
        });
      } else if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;

          final shouldCreate = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Product Not Found',
                  style: CustomTextStyles1.sectionHeader(context)),
              content: Text('No product found with barcode: $barcode',
                  style: CustomTextStyles1.tableCell(context)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Cancel',
                      style: CustomTextStyles1.buttonText(context)
                          .copyWith(color: Color(0xFF5CD2C6))),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Add Product',
                      style: CustomTextStyles1.buttonText(context)
                          .copyWith(color: Color(0xFF5CD2C6))),
                ),
              ],
            ),
          );

          if (shouldCreate == true && mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InventoryEditScreen(
                  productData: {'barcode': barcode},
                ),
              ),
            ).then((_) => _loadInventory());
          }
        });
      }
    } catch (e) {
      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error handling barcode: ${e.toString()}',
                    style: CustomTextStyles1.tableCell(context))),
          );
        }
      });
    }
  }

  Future<String?> _scanWithUsb() async {
    try {
      final barcode = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => BarcodeScannerScreen(
            onScan: (barcode) => Navigator.pop(context, barcode),
            showCamera: false,
            onError: (error) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(error,
                          style: CustomTextStyles1.tableCell(context))),
                );
              }
            },
          ),
        ),
      );
      return barcode;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('USB Error: ${e.toString()}',
                  style: CustomTextStyles1.tableCell(context))),
        );
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: ResponsiveUtils.isMobile(context)
          ? AppBar(
              title: Text(
                'Inventory',
                style: CustomTextStyles1.appBarTitle(context),
              ),
              backgroundColor: Colors.white,
              elevation: 1,
              actions: [
                IconButton(
                  icon: Icon(Icons.qr_code_scanner, color: Color(0xFF363753)),
                  onPressed: _startBarcodeScan,
                  tooltip: 'Scan Barcode',
                ),
              ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InventoryProductScreen(),
            ),
          ).then((_) => _loadInventory());
        },
        backgroundColor: Color(0xFF5CD2C6),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSearchBar(context),
          SizedBox(height: 16),
          _buildFilterSortRow(context),
          SizedBox(height: 16),
          _buildInventoryContent(context),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Inventory Management',
                      style: CustomTextStyles1.sectionHeader(context),
                    ),
                    IconButton(
                      icon:
                          Icon(Icons.qr_code_scanner, color: Color(0xFF363753)),
                      onPressed: _startBarcodeScan,
                      tooltip: 'Scan Barcode',
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildSearchBar(context),
                SizedBox(height: 16),
                _buildFilterSortRow(context),
                SizedBox(height: 16),
                _buildInventoryContent(context),
              ],
            ),
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
          ),
        ),
        _buildNavItem(context, '📊 SALES PERFORMANCE', '/dashboard', false),
        _buildNavItem(context, '📦 ORDERS', '/orders', false),
        _buildNavItem(context, '📋 INVENTORY', '/inventory', true),
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

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Color(0xFF6B7280)),
          hintText: 'Search products...',
          hintStyle: CustomTextStyles1.searchText(context),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: ResponsiveUtils.responsiveValue(
              context,
              mobile: 12,
              tablet: 14,
              desktop: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSortRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Filters: Category ▼',
          style: TextStyle(
            color: Color(0xFF363753),
            fontSize: ResponsiveUtils.responsiveValue(
              context,
              mobile: 12,
              tablet: 14,
              desktop: 16,
            ),
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          'Sort: Stock ▼',
          style: TextStyle(
            color: Color(0xFF363753),
            fontSize: ResponsiveUtils.responsiveValue(
              context,
              mobile: 12,
              tablet: 14,
              desktop: 16,
            ),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryContent(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _inventoryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _buildErrorWidget(context, snapshot.error.toString());
        }
        if (!snapshot.hasData || _filteredInventory.isEmpty) {
          return _buildEmptyWidget(context);
        }
        return _buildInventoryTable(context, _filteredInventory);
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 48),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Error: $error',
              style: CustomTextStyles1.tableCell(context)
                  .copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadInventory,
            child: Text(
              'Retry',
              style: CustomTextStyles1.buttonText(context),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF5CD2C6),
              padding: EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No inventory items found',
            style: CustomTextStyles1.tableCell(context)
                .copyWith(color: Colors.grey),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InventoryProductScreen(),
                ),
              ).then((_) => _loadInventory());
            },
            child: Text(
              'Add First Product',
              style: CustomTextStyles1.buttonText(context),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF5CD2C6),
              padding: EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTable(
      BuildContext context, List<Map<String, dynamic>> inventoryItems) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
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
              label: Text('Product',
                  style: CustomTextStyles1.tableHeader(context)),
            ),
            DataColumn(
              label:
                  Text('Code', style: CustomTextStyles1.tableHeader(context)),
            ),
            DataColumn(
              label: Text('Category',
                  style: CustomTextStyles1.tableHeader(context)),
            ),
            DataColumn(
              label:
                  Text('Price', style: CustomTextStyles1.tableHeader(context)),
              numeric: true,
            ),
            DataColumn(
              label:
                  Text('Stock', style: CustomTextStyles1.tableHeader(context)),
              numeric: true,
            ),
            DataColumn(
              label:
                  Text('Status', style: CustomTextStyles1.tableHeader(context)),
            ),
            DataColumn(
              label: Text('Actions',
                  style: CustomTextStyles1.tableHeader(context)),
            ),
          ],
          rows: inventoryItems
              .map((item) => _buildDataRow(context, item))
              .toList(),
        ),
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, Map<String, dynamic> item) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            item['product']?.toString() ?? 'N/A',
            style: CustomTextStyles1.tableCell(context),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataCell(
          Text(
            item['code']?.toString() ?? 'N/A',
            style: CustomTextStyles1.tableCell(context),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataCell(
          Text(
            item['category']?.toString() ?? 'Uncategorized',
            style: CustomTextStyles1.tableCell(context),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataCell(
          Text(
            '\$${(item['price'] ?? 0.0).toStringAsFixed(2)}',
            style: CustomTextStyles1.tableCell(context),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataCell(
          Text(
            item['current_stock']?.toString() ?? '0',
            style: CustomTextStyles1.tableCell(context),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataCell(
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: _getStatusColor(item).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              item['status']?.toString() ?? 'Unknown',
              style: CustomTextStyles1.tableCell(context).copyWith(
                color: _getStatusColor(item),
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionButton(
                context: context,
                text: 'Edit',
                color: Color(0xFF5CD2C6),
                onPressed: () async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          InventoryEditScreen(productData: item),
                    ),
                  );
                  if (updated == true) _loadInventory();
                },
              ),
              SizedBox(width: 8),
              _buildActionButton(
                context: context,
                text: 'View',
                color: Color(0xFF363753),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          InventoryViewScreen(productData: item),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
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
            tablet: 6,
            desktop: 8,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        text,
        style: CustomTextStyles1.buttonText(context).copyWith(
          color: color,
          fontSize: ResponsiveUtils.responsiveValue(
            context,
            mobile: 12,
            tablet: 13,
            desktop: 14,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(Map<String, dynamic> item) {
    final status = item['status']?.toString() ?? '';
    if (status.contains('Out')) return Colors.red;
    if (status.contains('Low')) return Colors.orange;
    return Colors.green;
  }
}
