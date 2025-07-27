import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'Inventory';

  static Future<List<Map<String, dynamic>>> getInventory() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'product': data['product']?.toString() ?? 'Unknown Product',
          'code': data['code']?.toString() ?? 'N/A',
          'category': data['category']?.toString() ?? 'Uncategorized',
          'price': _convertToDouble(data['price']),
          'current_stock': _convertToInt(data['current_stock']),
          'minimum_stock': _convertToInt(data['minimum_stock']),
          'barcode': data['barcode']?.toString() ?? '',
          'status': data['status']?.toString() ??
              _determineStockStatus(
                _convertToInt(data['current_stock']),
                _convertToInt(data['minimum_stock']),
              ),
        };
      }).toList();
    } catch (e) {
      print('Firestore Error: $e');
      throw Exception('Failed to load inventory. Please try again.');
    }
  }

  static int _convertToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _convertToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static Future<void> updateProduct(Map<String, dynamic> product) async {
    try {
      if (product['id'] == null) {
        throw Exception('Document ID is required for updates');
      }

      await _firestore.collection(_collectionName).doc(product['id']).update({
        'product': product['product']?.toString() ?? '',
        'code': product['code']?.toString() ?? '',
        'category': product['category']?.toString() ?? '',
        'price': _convertToDouble(product['price']),
        'current_stock': _convertToInt(product['current_stock']),
        'minimum_stock': _convertToInt(product['minimum_stock']),
        'barcode': product['barcode']?.toString() ?? '',
        'status': product['status']?.toString() ??
            _determineStockStatus(
              _convertToInt(product['current_stock']),
              _convertToInt(product['minimum_stock']),
            ),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Update Error: $e');
      throw Exception('Failed to update product: ${e.toString()}');
    }
  }

  static Future<String> addProduct(Map<String, dynamic> product) async {
    try {
      final docRef = await _firestore.collection(_collectionName).add({
        'product': product['product']?.toString() ?? '',
        'code': product['code']?.toString() ?? '',
        'category': product['category']?.toString() ?? '',
        'price': _convertToDouble(product['price']),
        'current_stock': _convertToInt(product['current_stock']),
        'minimum_stock': _convertToInt(product['minimum_stock']),
        'barcode': product['barcode']?.toString() ?? '',
        'status': product['status']?.toString() ?? 'In Stock',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('Add Product Error: $e');
      throw Exception('Failed to add new product: ${e.toString()}');
    }
  }

  static String _determineStockStatus(int currentStock, int minStock) {
    if (currentStock == 0) return 'Out of Stock';
    if (currentStock <= minStock) return 'Low Stock';
    return 'In Stock';
  }
}
