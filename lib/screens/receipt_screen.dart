import 'package:flutter/material.dart';
import '../widgets/receipt_style.dart';

class ReceiptScreen extends StatefulWidget {
  @override
  _ReceiptScreenState createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final TextEditingController _receiptTitleController =
      TextEditingController(text: 'Sales Tax Receipt');
  final TextEditingController _headerTextController = TextEditingController();
  final TextEditingController _footerTextController = TextEditingController(
      text:
          'Thanks for shopping with us! Your support means the world to us. See you again soon!');

  bool _showStoreInfo = true;
  bool _showTaxBreakdown = true;
  bool _showCustomerInfo = false;
  bool _showCashier = true;
  bool _showDiscounts = true;
  bool _showPaymentMethod = true;
  bool _showBarcode = false;
  bool _showReceiptSettings = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Receipt Header', style: ReceiptStyles.sectionHeaderStyle),
          const SizedBox(height: 20),
          Text('Receipt Title', style: ReceiptStyles.labelStyle),
          const SizedBox(height: 10),
          TextField(
            controller: _receiptTitleController,
            style: ReceiptStyles.textFieldStyle,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            ),
          ),
          const SizedBox(height: 20),
          Text('Header Text', style: ReceiptStyles.labelStyle),
          const SizedBox(height: 10),
          TextField(
            controller: _headerTextController,
            style: ReceiptStyles.textFieldStyle,
            maxLines: 3,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            ),
          ),
          const SizedBox(height: 40),
          Text('Receipt Options', style: ReceiptStyles.sectionHeaderStyle),
          const SizedBox(height: 20),
          _buildCheckboxOption('Show Store Information', _showStoreInfo, (val) {
            setState(() => _showStoreInfo = val ?? false);
          }),
          _buildCheckboxOption('Show Tax Breakdown', _showTaxBreakdown, (val) {
            setState(() => _showTaxBreakdown = val ?? false);
          }),
          _buildCheckboxOption('Show Customer Information', _showCustomerInfo,
              (val) {
            setState(() => _showCustomerInfo = val ?? false);
          }),
          _buildCheckboxOption('Show Cashier', _showCashier, (val) {
            setState(() => _showCashier = val ?? false);
          }),
          _buildCheckboxOption('Show Discounts', _showDiscounts, (val) {
            setState(() => _showDiscounts = val ?? false);
          }),
          _buildCheckboxOption('Show Payment Method', _showPaymentMethod,
              (val) {
            setState(() => _showPaymentMethod = val ?? false);
          }),
          const SizedBox(height: 40),
          Text('Receipt Footer', style: ReceiptStyles.sectionHeaderStyle),
          const SizedBox(height: 20),
          Text('Footer Text', style: ReceiptStyles.labelStyle),
          const SizedBox(height: 10),
          TextField(
            controller: _footerTextController,
            style: ReceiptStyles.textFieldStyle,
            maxLines: 3,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            ),
          ),
          const SizedBox(height: 20),
          _buildCheckboxOption('Show Barcode', _showBarcode, (val) {
            setState(() => _showBarcode = val ?? false);
          }),
          _buildCheckboxOption('Show Receipt Settings', _showReceiptSettings,
              (val) {
            setState(() => _showReceiptSettings = val ?? false);
          }),
          const SizedBox(height: 40),
          Center(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF363753),
                padding:
                    const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text('Save Receipt Settings',
                  style: ReceiptStyles.saveButtonStyle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxOption(
      String label, bool value, Function(bool?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
          ),
          Text(label, style: ReceiptStyles.checkboxTextStyle),
        ],
      ),
    );
  }
}
