import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:permission_handler/permission_handler.dart';
import '../widgets/orders_style.dart';
import '../widgets/app_sidebar.dart';
import 'payment_screen.dart';
import 'barcode_scanner_screen.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final List<Map<String, dynamic>> _cartItems = [];
  double _subtotal = 0.0;
  double _tax = 0.0;
  double _discount = 0.0;
  double _total = 0.0;
  String _deliveryOption = 'Pickup';
  String _searchQuery = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
        child: Row(
          children: [
            AppSidebar(currentScreen: 'orders'), // Pass 'orders' here
            Expanded(
              child: Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFFDFE3EE),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: _buildMainContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        // Search Bar with Scan Button
        Padding(
          padding: const EdgeInsets.all(20),
          child: _buildSearchBar(),
        ),

        // Main Content Area
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Products Grid
                  _buildProductGrid(),
                  SizedBox(height: 20),

                  // Cart Items
                  if (_cartItems.isNotEmpty) _buildCartItems(),

                  // Summary Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFF363753),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButton<String>(
                          value: _deliveryOption,
                          dropdownColor: Color(0xFF363753),
                          style: OrdersStyles.itemTextStyle
                              .copyWith(color: Colors.white),
                          items: ['Pickup', 'Delivery'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _deliveryOption = newValue!;
                            });
                          },
                        ),
                        SizedBox(height: 20),
                        _buildSummaryRow('Subtotal:', _subtotal),
                        _buildSummaryRow('Discount:', _discount),
                        _buildSummaryRow('Tax:', _tax),
                        SizedBox(height: 20),
                        _buildSummaryRow('TOTAL:', _total, isTotal: true),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _cartItems.isEmpty
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PaymentScreen(
                                          totalAmount: _total,
                                          items: _cartItems,
                                          orderId: _generateOrderId(),
                                        ),
                                      ),
                                    ).then((_) {
                                      setState(() {
                                        _cartItems.clear();
                                        _updateTotals();
                                      });
                                    });
                                  },
                            child: Text('PAY', style: TextStyle(fontSize: 24)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF5CD2C6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search product by code, description or barcode',
                hintStyle: OrdersStyles.searchTextStyle,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ),
        SizedBox(width: 8),
        IconButton(
          icon: Icon(Icons.qr_code_scanner),
          onPressed: _scanProduct,
          tooltip: 'Scan Barcode',
        ),
      ],
    );
  }

  Future<void> _scanProduct() async {
    final scanOption = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scan Barcode'),
        content: const Text('Choose scanning method:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'camera'),
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'usb'),
            child: const Text('USB Scanner'),
          ),
        ],
      ),
    );

    if (scanOption == 'camera') {
      await _scanWithCamera();
    } else if (scanOption == 'usb') {
      await _scanWithUsb();
    }
  }

  Future<void> _scanWithCamera() async {
    // Removed camera permission request as per the requirement
    // Removed camera permission check as per the requirement

    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeScannerScreen(
          onScan: (barcode) => Navigator.pop(context, barcode),
          showCamera: true,
        ),
      ),
    );

    if (barcode != null && barcode.isNotEmpty) {
      await _addProductByBarcode(barcode);
    }
  }

  Future<void> _scanWithUsb() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeScannerScreen(
          onScan: _addProductByBarcode,
          showCamera: false,
        ),
      ),
    );
  }

  Future<void> _addProductByBarcode(String barcode) async {
    if (!mounted) return;

    Navigator.pop(context); // Close scanner screen if open

    try {
      final productQuery = await _firestore
          .collection('Inventory')
          .where('barcode', isEqualTo: barcode)
          .limit(1)
          .get();

      if (productQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product not found for barcode: $barcode')),
        );
        return;
      }

      final product = productQuery.docs.first.data();
      final productId = productQuery.docs.first.id;
      final stock =
          int.tryParse(product['current_stock']?.toString() ?? '0') ?? 0;

      if (stock <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product is out of stock')),
        );
        return;
      }

      setState(() {
        final existingIndex =
            _cartItems.indexWhere((item) => item['id'] == productId);
        if (existingIndex >= 0) {
          if (_cartItems[existingIndex]['quantity'] < stock) {
            _cartItems[existingIndex]['quantity'] += 1;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Cannot add more than available stock')),
            );
          }
        } else {
          _cartItems.add({
            'id': productId,
            'name': product['product'] ?? 'Unknown Product',
            'price': (product['price'] ?? 0.0).toDouble(),
            'quantity': 1,
            'code': product['code'] ?? 'N/A',
          });
        }
        _updateTotals();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Widget _buildProductGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('Inventory')
          .where('status', isNotEqualTo: 'Out of Stock')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading products'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No products available'));
        }

        var products = snapshot.data!.docs;

        // Filter products based on search query
        if (_searchQuery.isNotEmpty) {
          products = products.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = data['product']?.toString().toLowerCase() ?? '';
            final code = data['code']?.toString().toLowerCase() ?? '';
            final barcode = data['barcode']?.toString().toLowerCase() ?? '';
            return name.contains(_searchQuery) ||
                code.contains(_searchQuery) ||
                barcode.contains(_searchQuery);
          }).toList();
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.5,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index].data() as Map<String, dynamic>;
            final productId = products[index].id;
            final stock =
                int.tryParse(product['current_stock']?.toString() ?? '0') ?? 0;

            return _buildProductCard(
              product['product'] ?? 'Unknown Product',
              (product['price'] ?? 0.0).toDouble(),
              stock,
              productId,
              product['code'] ?? 'N/A',
            );
          },
        );
      },
    );
  }

  Widget _buildProductCard(String productName, double price, int stock,
      String productId, String productCode) {
    return GestureDetector(
      onTap: () {
        if (stock > 0) {
          setState(() {
            // Check if product already in cart
            final existingIndex =
                _cartItems.indexWhere((item) => item['id'] == productId);
            if (existingIndex >= 0) {
              // Don't allow adding more than available stock
              if (_cartItems[existingIndex]['quantity'] < stock) {
                _cartItems[existingIndex]['quantity'] += 1;
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Cannot add more than available stock')),
                );
              }
            } else {
              _cartItems.add({
                'id': productId,
                'name': productName,
                'price': price,
                'quantity': 1,
                'code': productCode,
              });
            }
            _updateTotals();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Product is out of stock')),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: stock > 0
              ? (stock <= 10 ? Colors.orange : Color(0xFF5CD2C6))
              : Colors.grey,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                productName,
                style: OrdersStyles.itemTextStyle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 5),
            Text(
              '\$${price.toStringAsFixed(2)}',
              style: OrdersStyles.totalTextStyle,
            ),
            SizedBox(height: 5),
            Text(
              'Stock: $stock',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (productCode != 'N/A') ...[
              SizedBox(height: 5),
              Text(
                'Code: $productCode',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCartItems() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Cart Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              final item = _cartItems[index];
              return ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                leading: Text(
                  '${item['quantity']}x',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                title: Text(
                  item['name'],
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                subtitle: Text('Code: ${item['code']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        setState(() {
                          if (item['quantity'] > 1) {
                            item['quantity']--;
                          } else {
                            _cartItems.removeAt(index);
                          }
                          _updateTotals();
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: OrdersStyles.totalTextStyle.copyWith(
              color: Colors.white,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: OrdersStyles.totalTextStyle.copyWith(
              color: Colors.white,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _updateTotals() {
    _subtotal = _cartItems.fold(
        0.0, (sum, item) => sum + (item['price'] * item['quantity']));
    _tax = _subtotal * 0.1; // 10% tax
    _total = _subtotal + _tax - _discount;
    setState(() {});
  }

  String _generateOrderId() {
    return 'ORD-${DateTime.now().millisecondsSinceEpoch}';
  }
}
