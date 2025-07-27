import 'package:flutter/material.dart';
import '../widgets/inventory_view_style.dart';
import 'inventory_edit.dart';

class InventoryViewScreen extends StatelessWidget {
  final Map<String, dynamic> productData;

  const InventoryViewScreen({Key? key, required this.productData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFFEDEDEF)),
        child: Row(
          children: [
            _buildSidebar(context),
            Expanded(
              child: Stack(
                children: [
                  _buildMainContent(),
                  _buildBackButton(context),
                  _buildEditButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 180,
      color: const Color(0xFF363753),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildMenuItem('🏠 Dashboard', Colors.white, context),
                _buildMenuItem('📄 Orders', Colors.white, context),
                _buildMenuItem(
                    '📦 Inventory', const Color(0xFF5CD2C6), context),
                _buildMenuItem('📊 Reports', Colors.white, context),
                _buildMenuItem('⚙️ Settings', Colors.white, context),
                const SizedBox(height: 20),
                _buildMenuItem('LOGOUT', Colors.white, context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, Color color, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: InventoryViewStyles.menuTextStyle.copyWith(color: color),
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Inventory Management',
                style: InventoryViewStyles.titleTextStyle),
            const SizedBox(height: 16),
            Text('Product Details',
                style: InventoryViewStyles.detailsTitleTextStyle),
            const SizedBox(height: 16),
            const Divider(thickness: 1, color: Colors.black),
            const SizedBox(height: 24),
            _buildProductImage(),
            const SizedBox(height: 24),
            _buildProductInfoSection(),
            const SizedBox(height: 24),
            _buildStockInfoSection(),
            const SizedBox(height: 24),
            _buildDescriptionSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
          image: productData['image'] != null
              ? DecorationImage(
                  image: AssetImage(productData['image']),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: productData['image'] == null
            ? const Icon(
                Icons.inventory_2_outlined,
                size: 40,
                color: Color(0xFF363753),
              )
            : null,
      ),
    );
  }

  Widget _buildProductInfoSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildInfoColumn(
                    'Product name', productData['name'] ?? 'N/A')),
            const SizedBox(width: 16),
            Expanded(
                child: _buildInfoColumn(
                    'Item Code', productData['code'] ?? 'N/A')),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildInfoColumn(
                    'Category', productData['category'] ?? 'N/A')),
            const SizedBox(width: 16),
            Expanded(
                child: _buildInfoColumn(
                    'Barcode', productData['barcode'] ?? 'N/A')),
          ],
        ),
      ],
    );
  }

  Widget _buildStockInfoSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildInfoColumn('Price',
                    '\$${productData['price']?.toStringAsFixed(2) ?? '0.00'}')),
            const SizedBox(width: 16),
            Expanded(
                child: _buildInfoColumn('Cost',
                    '\$${productData['cost']?.toStringAsFixed(2) ?? '0.00'}')),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildInfoColumn(
                    'Current Stock', productData['stock']?.toString() ?? '0')),
            const SizedBox(width: 16),
            Expanded(child: _buildStockStatusColumn()),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: InventoryViewStyles.labelTextStyle),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(value, style: InventoryViewStyles.valueTextStyle),
        ),
      ],
    );
  }

  Widget _buildStockStatusColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Stock Status', style: InventoryViewStyles.labelTextStyle),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: _getStockStatusColor(),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _getStockStatus(),
            style: InventoryViewStyles.stockStatusTextStyle,
          ),
        ),
      ],
    );
  }

  String _getStockStatus() {
    final stock = int.tryParse(productData['stock']?.toString() ?? '0') ?? 0;
    final threshold =
        int.tryParse(productData['threshold']?.toString() ?? '10') ?? 10;

    if (stock == 0) return 'Out of Stock';
    if (stock <= threshold) return 'Low stock';
    return 'In Stock';
  }

  Color _getStockStatusColor() {
    final status = _getStockStatus();
    if (status == 'Out of Stock') return const Color(0x68EE1D20);
    if (status == 'Low stock') return const Color(0x66FFC107);
    return const Color(0x6628A745);
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Description', style: InventoryViewStyles.labelTextStyle),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            productData['description'] ?? 'No description available',
            style: InventoryViewStyles.descriptionTextStyle,
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF363753),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5CD2C6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onPressed: () => _navigateToEditScreen(context),
        child: Text(
          'Edit Product',
          style: InventoryViewStyles.menuTextStyle.copyWith(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _navigateToEditScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InventoryEditScreen(
          productData: productData,
        ),
      ),
    );
  }
}
