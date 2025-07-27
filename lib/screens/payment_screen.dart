import 'package:flutter/material.dart';
import '../services/payment_service.dart';
import 'receipt_screen_pdf.dart';
import '../widgets/app_sidebar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> items;
  final String orderId;

  const PaymentScreen({
    Key? key,
    required this.totalAmount,
    required this.items,
    required this.orderId,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  double _paidAmount = 0.0;
  String _paymentMethod = 'cash';
  bool _isProcessing = false;
  final TextEditingController _amountController = TextEditingController();
  final _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _paidAmount = widget.totalAmount;
    _amountController.text = widget.totalAmount.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _completePayment() async {
    if (_paidAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid payment amount')),
      );
      return;
    }

    setState(() => _isProcessing = true);
    try {
      // Process items with type conversion
      final processedItems = widget.items
          .map((item) => {
                'id': item['id']?.toString() ?? '',
                'name': item['name']?.toString() ?? 'Unknown',
                'price': PaymentService.convertToDouble(item['price']),
                'quantity': PaymentService.convertToInt(item['quantity']),
                'code': item['code']?.toString() ?? '',
              })
          .toList();

      final paymentId = await PaymentService.processPayment(
        orderId: widget.orderId,
        totalAmount: widget.totalAmount,
        paidAmount: _paidAmount,
        paymentMethod: _paymentMethod,
        items: processedItems,
        cashierName: _user?.displayName ?? 'Cashier',
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptPdfScreen(paymentId: paymentId),
        ),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Payment failed: ${e.toString().replaceAll('Exception:', '').trim()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final balance =
        (widget.totalAmount - _paidAmount).clamp(0, widget.totalAmount);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFFEDEDEF)),
        child: Row(
          children: [
            AppSidebar(currentScreen: 'orders'),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PAYMENT',
                          style: TextStyle(
                              fontSize: 48, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildPaymentInfoCard(
                              'Total',
                              '\$${widget.totalAmount.toStringAsFixed(2)}',
                              const Color(0xFFEE1D20)),
                          _buildPaymentInfoCard(
                              'Paid',
                              '\$${_paidAmount.toStringAsFixed(2)}',
                              const Color(0xFF6D56D5)),
                          _buildPaymentInfoCard(
                              'Balance',
                              '\$${balance.toStringAsFixed(2)}',
                              balance > 0
                                  ? Colors.orange
                                  : const Color(0xFF5CD2C6)),
                        ],
                      ),
                      const SizedBox(height: 30),
                      const Text('Amount To Receive',
                          style: TextStyle(fontSize: 40)),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Enter amount',
                                ),
                                onChanged: (value) {
                                  final amount = double.tryParse(value) ?? 0.0;
                                  setState(() {
                                    _paidAmount =
                                        amount.clamp(0, widget.totalAmount);
                                    if (value.isNotEmpty &&
                                        amount > widget.totalAmount) {
                                      _amountController.text =
                                          widget.totalAmount.toStringAsFixed(2);
                                    }
                                  });
                                },
                              ),
                            ),
                            Text(
                              '\$${balance.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: balance > 0
                                    ? Colors.orange
                                    : const Color(0xFF5CD2C6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          _buildPaymentMethodButton('Cash', Icons.money),
                          _buildPaymentMethodButton('Card', Icons.credit_card),
                          _buildPaymentMethodButton(
                              'Gift Card', Icons.card_giftcard),
                          _buildPaymentMethodButton('QR Code', Icons.qr_code),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : _completePayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5CD2C6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: _isProcessing
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text('COMPLETE PAYMENT',
                                  style: TextStyle(fontSize: 24)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodButton(String method, IconData icon) {
    final isSelected = _paymentMethod == method.toLowerCase();
    return GestureDetector(
      onTap: () {
        setState(() {
          _paymentMethod = method.toLowerCase();
          if (method == 'Cash') {
            _amountController.text = widget.totalAmount.toStringAsFixed(2);
            _paidAmount = widget.totalAmount;
          } else {
            _amountController.clear();
            _paidAmount = 0.0;
          }
        });
      },
      child: Container(
        width: 150,
        height: 100,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF363753)
              : const Color(0xFF363753).withOpacity(0.7),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 10),
            Text(method,
                style: const TextStyle(color: Colors.white, fontSize: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfoCard(String label, String amount, Color color) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 24)),
          const SizedBox(height: 10),
          Text(amount,
              style: TextStyle(
                  color: color, fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
