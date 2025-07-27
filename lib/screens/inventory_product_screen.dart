import 'package:flutter/material.dart';
import '../services/inventory_service.dart';

class InventoryProductScreen extends StatefulWidget {
  final Map<String, dynamic>? productData;

  const InventoryProductScreen({Key? key, this.productData}) : super(key: key);

  @override
  _InventoryProductScreenState createState() => _InventoryProductScreenState();
}

class _InventoryProductScreenState extends State<InventoryProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productController = TextEditingController();
  final _codeController = TextEditingController();
  final _categoryController = TextEditingController();
  final _stockController = TextEditingController();
  final _minStockController = TextEditingController();
  final _priceController = TextEditingController();
  final _barcodeController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.productData != null) {
      _productController.text =
          widget.productData!['product']?.toString() ?? '';
      _codeController.text = widget.productData!['code']?.toString() ?? '';
      _categoryController.text =
          widget.productData!['category']?.toString() ?? '';
      _stockController.text =
          widget.productData!['current_stock']?.toString() ?? '0';
      _minStockController.text =
          widget.productData!['minimum_stock']?.toString() ?? '0';
      _priceController.text =
          (widget.productData!['price']?.toStringAsFixed(2)) ?? '0.00';
      _barcodeController.text =
          widget.productData!['barcode']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _productController.dispose();
    _codeController.dispose();
    _categoryController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _priceController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final productData = {
          'product': _productController.text.trim(),
          'code': _codeController.text.trim(),
          'category': _categoryController.text.trim(),
          'current_stock': int.tryParse(_stockController.text) ?? 0,
          'minimum_stock': int.tryParse(_minStockController.text) ?? 0,
          'price': double.tryParse(_priceController.text) ?? 0.0,
          'barcode': _barcodeController.text.trim(),
          'status': _getStockStatus(
            int.tryParse(_stockController.text) ?? 0,
            int.tryParse(_minStockController.text) ?? 0,
          ),
        };

        if (widget.productData != null) {
          productData['id'] = widget.productData!['id'];
          await InventoryService.updateProduct(productData);
        } else {
          await InventoryService.addProduct(productData);
        }

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.productData != null ? 'Edit Product' : 'Add Product'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildInputField('Product Name', _productController,
                        isRequired: true),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                            child: _buildInputField(
                                'Item Code', _codeController,
                                isRequired: true)),
                        const SizedBox(width: 16),
                        Expanded(
                            child: _buildInputField(
                                'Barcode', _barcodeController)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInputField('Category', _categoryController,
                        isRequired: true),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                            child: _buildInputField(
                                'Current Stock', _stockController,
                                isNumber: true, isRequired: true)),
                        const SizedBox(width: 16),
                        Expanded(
                            child: _buildInputField(
                                'Minimum Stock', _minStockController,
                                isNumber: true, isRequired: true)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInputField('Price (\$)', _priceController,
                        isNumber: true, isRequired: true),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed:
                              _isLoading ? null : () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          child: const Text('Save Product'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    bool isRequired = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: isNumber
          ? TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      validator: isRequired
          ? (value) {
              if (value == null || value.isEmpty)
                return 'This field is required';
              if (isNumber) {
                if (isNumber && double.tryParse(value) == null) {
                  return 'Enter a valid number';
                }
              }
              return null;
            }
          : null,
    );
  }
}
