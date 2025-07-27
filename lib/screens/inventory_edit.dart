import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/inventory_service.dart';
import '../widgets/inventory_edit_style.dart';
import '../widgets/app_sidebar.dart';

class InventoryEditScreen extends StatefulWidget {
  final Map<String, dynamic> productData;

  const InventoryEditScreen({Key? key, required this.productData})
      : super(key: key);

  @override
  _InventoryEditScreenState createState() => _InventoryEditScreenState();
}

class _InventoryEditScreenState extends State<InventoryEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _thresholdController;
  late TextEditingController _barcodeController;

  bool _isLoading = false;
  bool _isNewProduct = true;

  @override
  void initState() {
    super.initState();
    _isNewProduct = widget.productData['id'] == null;

    // Initialize controllers with proper null checks
    _nameController = TextEditingController(
      text: widget.productData['product']?.toString() ?? '',
    );
    _codeController = TextEditingController(
      text: widget.productData['code']?.toString() ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.productData['category']?.toString() ?? '',
    );
    _priceController = TextEditingController(
      text: (widget.productData['price'] ?? 0.0).toStringAsFixed(2),
    );
    _stockController = TextEditingController(
      text: (widget.productData['current_stock'] ?? 0).toString(),
    );
    _thresholdController = TextEditingController(
      text: (widget.productData['minimum_stock'] ?? 1).toString(),
    );
    _barcodeController = TextEditingController(
      text: widget.productData['barcode']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _thresholdController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(currentScreen: 'inventory'),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isNewProduct ? 'Add Product' : 'Edit Product',
                              style: InventoryEditStyles.titleTextStyle,
                            ),
                            const SizedBox(height: 30),
                            _buildProductNameField(),
                            const SizedBox(height: 20),
                            _buildCodeField(),
                            const SizedBox(height: 20),
                            _buildBarcodeField(),
                            const SizedBox(height: 20),
                            _buildCategoryField(),
                            const SizedBox(height: 20),
                            _buildStockFields(),
                            const SizedBox(height: 20),
                            _buildPriceField(),
                            const SizedBox(height: 40),
                            _buildActionButtons(),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductNameField() {
    return _buildInputField(
      'Product Name',
      _nameController,
      isRequired: true,
    );
  }

  Widget _buildCodeField() {
    return _buildInputField(
      'Item Code',
      _codeController,
      isRequired: true,
    );
  }

  Widget _buildBarcodeField() {
    return _buildInputField(
      'Barcode',
      _barcodeController,
    );
  }

  Widget _buildCategoryField() {
    return _buildInputField(
      'Category',
      _categoryController,
      isRequired: true,
    );
  }

  Widget _buildStockFields() {
    return Row(
      children: [
        Expanded(
          child: _buildInputField(
            'Current Stock',
            _stockController,
            isNumber: true,
            isRequired: true,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildInputField(
            'Minimum Stock',
            _thresholdController,
            isNumber: true,
            isRequired: true,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceField() {
    return _buildInputField(
      'Price (\$)',
      _priceController,
      isNumber: true,
      isRequired: true,
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: InventoryEditStyles.labelTextStyle,
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(minHeight: 60),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: isNumber
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            validator: isRequired
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    if (isNumber && double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  }
                : null,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFFEE1D20),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'CANCEL',
            style: InventoryEditStyles.buttonTextStyle,
          ),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveProduct,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF28A745),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            _isNewProduct ? 'SAVE PRODUCT' : 'UPDATE PRODUCT',
            style: InventoryEditStyles.buttonTextStyle,
          ),
        ),
      ],
    );
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final productData = {
          'product': _nameController.text.trim(),
          'code': _codeController.text.trim(),
          'category': _categoryController.text.trim(),
          'price': double.tryParse(_priceController.text) ?? 0.0,
          'current_stock': int.tryParse(_stockController.text) ?? 0,
          'minimum_stock': int.tryParse(_thresholdController.text) ?? 1,
          'barcode': _barcodeController.text.trim(),
          'status': _getStockStatus(
            int.tryParse(_stockController.text) ?? 0,
            int.tryParse(_thresholdController.text) ?? 1,
          ),
          'updated_at': FieldValue.serverTimestamp(),
        };

        if (!_isNewProduct) {
          productData['id'] = widget.productData['id'];
          await InventoryService.updateProduct(productData);
        } else {
          productData['created_at'] = FieldValue.serverTimestamp();
          await InventoryService.addProduct(productData);
        }

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving product: ${e.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getStockStatus(int currentStock, int minStock) {
    if (currentStock == 0) return 'Out of Stock';
    if (currentStock <= minStock) return 'Low Stock';
    return 'In Stock';
  }
}
