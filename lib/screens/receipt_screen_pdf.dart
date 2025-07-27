import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import '../services/payment_service.dart';

class ReceiptPdfScreen extends StatelessWidget {
  final String paymentId;

  const ReceiptPdfScreen({Key? key, required this.paymentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printReceipt(context),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: PaymentService.getReceiptData(paymentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error loading receipt: ${snapshot.error}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back to Payment'),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No receipt data found'));
          }

          return PdfPreview(
            build: (format) => _generatePdf(snapshot.data!),
          );
        },
      ),
    );
  }

  Future<void> _printReceipt(BuildContext context) async {
    try {
      final receiptData = await PaymentService.getReceiptData(paymentId);
      await Printing.layoutPdf(
        onLayout: (format) => _generatePdf(receiptData),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Printing failed: $e')),
      );
    }
  }

  Future<Uint8List> _generatePdf(Map<String, dynamic> receiptData) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Company Info
              pw.Text(receiptData['company_info']['name'] ?? 'Unknown Company',
                  style: const pw.TextStyle(fontSize: 20)),
              pw.Text(receiptData['company_info']['address'] ?? 'No Address'),
              pw.Text(receiptData['company_info']['phone'] ?? 'No Phone'),
              pw.Text('VAT: ${receiptData['company_info']['vat'] ?? 'N/A'}'),
              pw.Text('TIN: ${receiptData['company_info']['tin'] ?? 'N/A'}'),
              pw.Divider(),

              // Receipt Title
              pw.Center(
                child: pw.Text(
                  'RECEIPT / TAX INVOICE',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),

              // Items Table
              pw.Table.fromTextArray(
                context: context,
                data: [
                  ['Qty', 'Description', 'Price', 'Total'],
                  ...receiptData['items']?.map((item) => [
                            item['quantity'].toString(),
                            item['name'] ?? 'Unknown Item',
                            '\$${item['price']?.toStringAsFixed(2) ?? '0.00'}',
                            '\$${(item['quantity'] * (item['price'] ?? 0)).toStringAsFixed(2)}',
                          ]) ??
                      [],
                ],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerRight,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                },
              ),
              pw.Divider(),

              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('SUBTOTAL (INC Tax):'),
                  pw.Text(
                      '\$${receiptData['subtotal']?.toStringAsFixed(2) ?? '0.00'}'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL:'),
                  pw.Text(
                    '\$${receiptData['total']?.toStringAsFixed(2) ?? '0.00'}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Payment Info
              pw.Text('PAYMENTS',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Payment Method:'),
                  pw.Text(
                      receiptData['payment_method']?.toString().toUpperCase() ??
                          'N/A'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Cashier:'),
                  pw.Text(receiptData['cashier'] ?? 'Unknown Cashier'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Date:'),
                  pw.Text(receiptData['date'] ?? 'No Date'),
                ],
              ),
              pw.SizedBox(height: 20),

              // Footer
              pw.Center(
                child: pw.Text(
                  'Thanks for shopping with us! Your support means the world to us. See you again soon!',
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
