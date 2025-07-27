import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Type conversion helpers with improved error handling
  static int _convertToInt(dynamic value) {
    try {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        // Handle empty strings and non-numeric strings
        final trimmed = value.trim();
        if (trimmed.isEmpty) return 0;
        return int.tryParse(trimmed) ?? 0;
      }
      return 0;
    } catch (e) {
      return 0; // Fallback to 0 on any conversion error
    }
  }

  static double _convertToDouble(dynamic value) {
    try {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        // Handle empty strings and non-numeric strings
        final trimmed = value.trim();
        if (trimmed.isEmpty) return 0.0;
        return double.tryParse(trimmed) ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      return 0.0; // Fallback to 0.0 on any conversion error
    }
  }

  // Public wrapper methods for external use
  static int convertToInt(dynamic value) => _convertToInt(value);
  static double convertToDouble(dynamic value) => _convertToDouble(value);

  /// Processes a payment transaction with comprehensive error handling
  static Future<String> processPayment({
    required String orderId,
    required double totalAmount,
    required double paidAmount,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
    String? cashierName,
  }) async {
    try {
      // Validate input parameters
      if (totalAmount <= 0) throw Exception('Total amount must be positive');
      if (paidAmount < 0) throw Exception('Paid amount cannot be negative');
      if (paymentMethod.isEmpty) throw Exception('Payment method is required');
      if (items.isEmpty) throw Exception('Order must contain items');

      final batch = _firestore.batch();
      final currentUser = _auth.currentUser;
      final cashier = cashierName ?? currentUser?.displayName ?? 'Cashier';
      final balance = (totalAmount - paidAmount).clamp(0, totalAmount);
      final paymentStatus = balance > 0 ? 'partial' : 'completed';
      final now = FieldValue.serverTimestamp();

      // Process inventory updates with stock validation
      for (final item in items) {
        final productId = item['id']?.toString();
        if (productId == null || productId.isEmpty) {
          throw Exception('Item ID is missing for product: ${item['name']}');
        }

        final productRef = _firestore.collection('Inventory').doc(productId);
        final doc = await productRef.get();

        if (!doc.exists) {
          throw Exception('Product not found: ${item['name']}');
        }

        final currentStock = _convertToInt(doc.data()?['current_stock']);
        final quantity = _convertToInt(item['quantity']);

        if (quantity <= 0) {
          throw Exception('Invalid quantity for ${item['name']}');
        }

        final newStock = currentStock - quantity;
        if (newStock < 0) {
          throw Exception(
              'Insufficient stock for ${item['name']} (Available: $currentStock, Requested: $quantity)');
        }

        // Determine stock status
        final minStock = _convertToInt(doc.data()?['minimum_stock'] ?? 5);
        String status = 'In Stock';
        if (newStock <= 0) {
          status = 'Out of Stock';
        } else if (newStock <= minStock) {
          status = 'Low Stock';
        }

        batch.update(productRef, {
          'current_stock': newStock,
          'status': status,
          'updated_at': now,
        });
      }

      // Create payment document with complete transaction details
      final paymentRef = _firestore.collection('Payments').doc();
      final processedItems = items
          .map((item) => {
                'id': item['id']?.toString() ?? '',
                'name': item['name']?.toString() ?? 'Unknown Product',
                'price': _convertToDouble(item['price']),
                'quantity': _convertToInt(item['quantity']),
                'code': item['code']?.toString() ?? '',
                'category': item['category']?.toString() ?? 'Uncategorized',
              })
          .toList();

      batch.set(paymentRef, {
        'payment_id': paymentRef.id,
        'order_id': orderId,
        'total_amount': totalAmount,
        'paid_amount': paidAmount,
        'balance': balance,
        'payment_method': paymentMethod,
        'items': processedItems,
        'cashier': cashier,
        'cashier_uid': currentUser?.uid,
        'payment_date': now,
        'status': paymentStatus,
        'tax_amount': _calculateTax(totalAmount),
        'discount_amount': 0.0, // Can be extended to support discounts
      });

      // Create or update order document
      final orderRef = _firestore.collection('Orders').doc(orderId);
      batch.set(orderRef, {
        'order_id': orderId,
        'total_amount': totalAmount,
        'paid_amount': paidAmount,
        'balance': balance,
        'payment_status': paymentStatus,
        'items': processedItems,
        'created_at': now,
        'updated_at': now,
        'status': 'completed',
        'customer_id': '', // Can be extended to support customers
        'delivery_option': 'pickup', // Default delivery option
      });

      // Create receipt document
      final receiptRef = _firestore.collection('Receipts').doc(paymentRef.id);
      batch.set(receiptRef, {
        'receipt_id': paymentRef.id,
        'order_id': orderId,
        'payment_id': paymentRef.id,
        'amount': totalAmount,
        'date': now,
        'items': processedItems.length,
        'cashier': cashier,
      });

      await batch.commit();
      return paymentRef.id;
    } on FirebaseException catch (e) {
      throw Exception('Firestore error: ${e.message}');
    } catch (e) {
      throw Exception('Payment processing failed: ${e.toString()}');
    }
  }

  /// Calculates tax amount (10% by default, can be customized)
  static double _calculateTax(double amount, {double taxRate = 0.1}) {
    return (amount * taxRate).roundToDouble();
  }

  /// Retrieves detailed receipt data for display or printing
  static Future<Map<String, dynamic>> getReceiptData(String paymentId) async {
    try {
      final doc = await _firestore.collection('Payments').doc(paymentId).get();
      if (!doc.exists) throw Exception('Payment not found');

      final data = doc.data()!;
      final paymentDate = (data['payment_date'] as Timestamp).toDate();
      final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
      final subtotal = _convertToDouble(data['total_amount']) -
          _convertToDouble(data['tax_amount']);

      return {
        'company_info': await _getCompanyInfo(),
        'payment_info': {
          'payment_id': paymentId,
          'order_id': data['order_id']?.toString() ?? '',
          'payment_method': data['payment_method']?.toString() ?? 'Unknown',
          'date': _formatDate(paymentDate),
          'time': _formatTime(paymentDate),
        },
        'items': items,
        'subtotal': subtotal,
        'tax_amount': _convertToDouble(data['tax_amount']),
        'discount_amount': _convertToDouble(data['discount_amount'] ?? 0.0),
        'total': _convertToDouble(data['total_amount']),
        'cashier': data['cashier']?.toString() ?? 'Cashier',
        'balance': _convertToDouble(data['balance'] ?? 0.0),
      };
    } catch (e) {
      throw Exception('Failed to get receipt data: ${e.toString()}');
    }
  }

  /// Fetches company information from Firestore
  static Future<Map<String, dynamic>> _getCompanyInfo() async {
    try {
      final doc = await _firestore.collection('Settings').doc('company').get();
      if (doc.exists) {
        return {
          'name': doc.data()?['name'] ?? 'Your Store',
          'address':
              doc.data()?['address'] ?? '123 Business Street\nCity, Country',
          'phone': doc.data()?['phone'] ?? '+1 234 567 8900',
          'email': doc.data()?['email'] ?? 'info@yourstore.com',
          'vat': doc.data()?['vat'] ?? 'VAT123456789',
          'logo_url': doc.data()?['logo_url'] ?? '',
        };
      }
      return _defaultCompanyInfo();
    } catch (e) {
      return _defaultCompanyInfo();
    }
  }

  static Map<String, dynamic> _defaultCompanyInfo() {
    return {
      'name': 'Your Store',
      'address': '123 Business Street\nCity, Country',
      'phone': '+1 234 567 8900',
      'email': 'info@yourstore.com',
      'vat': 'VAT123456789',
      'logo_url': '',
    };
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}:'
        '${date.second.toString().padLeft(2, '0')}';
  }

  /// Retrieves payment history for a specific order
  static Future<List<Map<String, dynamic>>> getOrderPayments(
      String orderId) async {
    try {
      final query = await _firestore
          .collection('Payments')
          .where('order_id', isEqualTo: orderId)
          .orderBy('payment_date', descending: true)
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        final date = (data['payment_date'] as Timestamp).toDate();
        return {
          'id': doc.id,
          'amount': _convertToDouble(data['paid_amount']),
          'method': data['payment_method']?.toString() ?? 'Unknown',
          'date': _formatDate(date),
          'time': _formatTime(date),
          'status': data['status']?.toString() ?? 'completed',
          'cashier': data['cashier']?.toString() ?? 'Cashier',
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get payment history: ${e.toString()}');
    }
  }

  /// Updates a payment record (for partial payments or corrections)
  static Future<void> updatePayment({
    required String paymentId,
    double? paidAmount,
    String? paymentMethod,
    String? status,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (paidAmount != null) updateData['paid_amount'] = paidAmount;
      if (paymentMethod != null) updateData['payment_method'] = paymentMethod;
      if (status != null) updateData['status'] = status;

      await _firestore.collection('Payments').doc(paymentId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update payment: ${e.toString()}');
    }
  }
}
