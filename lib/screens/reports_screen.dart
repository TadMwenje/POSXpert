// reports_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:printing/printing.dart';
import 'package:file_saver/file_saver.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import '../widgets/custom_text_styles1.dart';
import '../widgets/responsive_utils.dart';
import '../widgets/app_sidebar.dart';
import '../services/inventory_service.dart';
import '../services/payment_service.dart';
import 'dart:js_interop'; // Add this import
import 'package:web/web.dart' as web; // Add this import
import 'package:universal_platform/universal_platform.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:io' if (dart.library.html) 'dart:html' as io;
// For platform detection Use this to check platform

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedReportType = 'sales';
  String _selectedFormat = 'pdf';
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(Duration(days: 30)),
    end: DateTime.now(),
  );
  bool _isGenerating = false;
  List<Map<String, dynamic>> _reportData = [];
  Map<String, dynamic> _reportSummary = {};

  final Map<String, String> _reportTypes = {
    'sales': 'Sales Report',
    'inventory': 'Inventory Report',
    'orders': 'Orders Report',
    'payments': 'Payments Report',
    'products': 'Top Products',
    'categories': 'Category Performance',
    'cashiers': 'Cashier Performance',
  };

  final Map<String, String> _formatTypes = {
    'pdf': 'PDF',
    'excel': 'Excel',
    'csv': 'CSV',
  };

  @override
  void initState() {
    super.initState();
    _generateReport();
  }

  Future<void> _generateReport() async {
    setState(() => _isGenerating = true);

    try {
      switch (_selectedReportType) {
        case 'sales':
          await _generateSalesReport();
          break;
        case 'inventory':
          await _generateInventoryReport();
          break;
        case 'orders':
          await _generateOrdersReport();
          break;
        case 'payments':
          await _generatePaymentsReport();
          break;
        case 'products':
          await _generateProductsReport();
          break;
        case 'categories':
          await _generateCategoriesReport();
          break;
        case 'cashiers':
          await _generateCashiersReport();
          break;
      }
    } catch (e) {
      print('Error generating report: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate report: ${e.toString()}')),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _generateSalesReport() async {
    final payments = await _firestore
        .collection('Payments')
        .where('payment_date',
            isGreaterThan: Timestamp.fromDate(_dateRange.start))
        .where('payment_date',
            isLessThan:
                Timestamp.fromDate(_dateRange.end.add(Duration(days: 1))))
        .get();

    double totalRevenue = 0;
    double totalTax = 0;
    int totalTransactions = 0;
    Map<String, double> paymentMethodTotals = {};

    _reportData = payments.docs.map((doc) {
      final data = doc.data();
      final amount = PaymentService.convertToDouble(data['total_amount']);
      final tax = PaymentService.convertToDouble(data['tax_amount']);
      final method = data['payment_method']?.toString() ?? 'Unknown';

      totalRevenue += amount;
      totalTax += tax;
      totalTransactions++;
      paymentMethodTotals.update(method, (value) => value + amount,
          ifAbsent: () => amount);

      return {
        'date': (data['payment_date'] as Timestamp).toDate(),
        'order_id': data['order_id'] ?? '',
        'amount': amount,
        'tax': tax,
        'method': method,
        'cashier': data['cashier'] ?? 'Unknown',
      };
    }).toList();

    _reportSummary = {
      'total_revenue': totalRevenue,
      'total_tax': totalTax,
      'total_transactions': totalTransactions,
      'payment_methods': paymentMethodTotals,
      'average_transaction':
          totalTransactions > 0 ? totalRevenue / totalTransactions : 0,
    };
  }

  Future<void> _generateInventoryReport() async {
    final inventory = await InventoryService.getInventory();

    int totalItems = 0;
    int lowStockItems = 0;
    int outOfStockItems = 0;
    double totalValue = 0;
    Map<String, int> categoryCounts = {};

    _reportData = inventory.map((item) {
      final stock = item['current_stock'] as int;
      final value = (item['price'] as double) * stock;

      totalItems++;
      totalValue += value;

      if (stock == 0)
        outOfStockItems++;
      else if (stock <= (item['minimum_stock'] as int)) lowStockItems++;

      categoryCounts.update(
          item['category']?.toString() ?? 'Uncategorized', (count) => count + 1,
          ifAbsent: () => 1);

      return {
        'product': item['product'],
        'code': item['code'],
        'category': item['category'],
        'stock': stock,
        'min_stock': item['minimum_stock'],
        'price': item['price'],
        'value': value,
        'status': item['status'],
      };
    }).toList();

    _reportSummary = {
      'total_items': totalItems,
      'low_stock_items': lowStockItems,
      'out_of_stock_items': outOfStockItems,
      'total_value': totalValue,
      'category_counts': categoryCounts,
    };
  }

  Future<void> _generateOrdersReport() async {
    final orders = await _firestore
        .collection('Orders')
        .where('created_at',
            isGreaterThan: Timestamp.fromDate(_dateRange.start))
        .where('created_at',
            isLessThan:
                Timestamp.fromDate(_dateRange.end.add(Duration(days: 1))))
        .get();

    double totalOrderValue = 0;
    int totalOrders = 0;
    int completedOrders = 0;
    Map<String, int> statusCounts = {};

    _reportData = orders.docs.map((doc) {
      final data = doc.data();
      final amount = PaymentService.convertToDouble(data['total_amount']);
      final status = data['status']?.toString() ?? 'unknown';

      totalOrderValue += amount;
      totalOrders++;
      statusCounts.update(status, (count) => count + 1, ifAbsent: () => 1);
      if (status == 'completed') completedOrders++;

      return {
        'order_id': data['order_id'] ?? doc.id,
        'date': (data['created_at'] as Timestamp).toDate(),
        'amount': amount,
        'status': status,
        'items': (data['items'] as List).length,
        'payment_status': data['payment_status'] ?? 'unknown',
      };
    }).toList();

    _reportSummary = {
      'total_orders': totalOrders,
      'completed_orders': completedOrders,
      'total_value': totalOrderValue,
      'status_counts': statusCounts,
      'average_order_value':
          totalOrders > 0 ? totalOrderValue / totalOrders : 0,
    };
  }

  Future<void> _generatePaymentsReport() async {
    final payments = await _firestore
        .collection('Payments')
        .where('payment_date',
            isGreaterThan: Timestamp.fromDate(_dateRange.start))
        .where('payment_date',
            isLessThan:
                Timestamp.fromDate(_dateRange.end.add(Duration(days: 1))))
        .get();

    double totalAmount = 0;
    Map<String, double> methodTotals = {};
    Map<String, int> methodCounts = {};

    _reportData = payments.docs.map((doc) {
      final data = doc.data();
      final amount = PaymentService.convertToDouble(data['paid_amount']);
      final method = data['payment_method']?.toString() ?? 'Unknown';

      totalAmount += amount;
      methodTotals.update(method, (value) => value + amount,
          ifAbsent: () => amount);
      methodCounts.update(method, (count) => count + 1, ifAbsent: () => 1);

      return {
        'payment_id': data['payment_id'] ?? doc.id,
        'date': (data['payment_date'] as Timestamp).toDate(),
        'order_id': data['order_id'] ?? '',
        'amount': amount,
        'method': method,
        'cashier': data['cashier'] ?? 'Unknown',
        'status': data['status'] ?? 'completed',
      };
    }).toList();

    _reportSummary = {
      'total_amount': totalAmount,
      'method_totals': methodTotals,
      'method_counts': methodCounts,
      'total_transactions': payments.size,
    };
  }

  Future<void> _generateProductsReport() async {
    final payments = await _firestore
        .collection('Payments')
        .where('payment_date',
            isGreaterThan: Timestamp.fromDate(_dateRange.start))
        .where('payment_date',
            isLessThan:
                Timestamp.fromDate(_dateRange.end.add(Duration(days: 1))))
        .get();

    Map<String, Map<String, dynamic>> productStats = {};

    for (final doc in payments.docs) {
      final data = doc.data();
      final items = List<Map<String, dynamic>>.from(data['items'] ?? []);

      for (final item in items) {
        final productId = item['id']?.toString() ?? '';
        final productName = item['name']?.toString() ?? 'Unknown';
        final quantity = PaymentService.convertToInt(item['quantity']);
        final price = PaymentService.convertToDouble(item['price']);
        final revenue = price * quantity;

        if (productStats.containsKey(productId)) {
          productStats[productId]!['quantity'] += quantity;
          productStats[productId]!['revenue'] += revenue;
          productStats[productId]!['transactions']++;
        } else {
          productStats[productId] = {
            'name': productName,
            'quantity': quantity,
            'revenue': revenue,
            'transactions': 1,
            'category': item['category']?.toString() ?? 'Uncategorized',
          };
        }
      }
    }

    _reportData = productStats.entries.map((entry) {
      return {
        'product_id': entry.key,
        'product_name': entry.value['name'],
        'quantity_sold': entry.value['quantity'],
        'revenue': entry.value['revenue'],
        'transactions': entry.value['transactions'],
        'category': entry.value['category'],
      };
    }).toList();

    // Sort by revenue descending
    _reportData.sort(
        (a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double));

    _reportSummary = {
      'total_products': _reportData.length,
      'total_revenue': _reportData.fold(
          0.0, (sum, item) => sum + (item['revenue'] as double)),
      'total_quantity': _reportData.fold(
          0, (sum, item) => sum + (item['quantity_sold'] as int)),
    };
  }

  Future<void> _generateCategoriesReport() async {
    final payments = await _firestore
        .collection('Payments')
        .where('payment_date',
            isGreaterThan: Timestamp.fromDate(_dateRange.start))
        .where('payment_date',
            isLessThan:
                Timestamp.fromDate(_dateRange.end.add(Duration(days: 1))))
        .get();

    Map<String, Map<String, dynamic>> categoryStats = {};

    for (final doc in payments.docs) {
      final data = doc.data();
      final items = List<Map<String, dynamic>>.from(data['items'] ?? []);

      for (final item in items) {
        final category = item['category']?.toString() ?? 'Uncategorized';
        final quantity = PaymentService.convertToInt(item['quantity']);
        final price = PaymentService.convertToDouble(item['price']);
        final revenue = price * quantity;

        if (categoryStats.containsKey(category)) {
          categoryStats[category]!['quantity'] += quantity;
          categoryStats[category]!['revenue'] += revenue;
          categoryStats[category]!['transactions']++;
        } else {
          categoryStats[category] = {
            'quantity': quantity,
            'revenue': revenue,
            'transactions': 1,
          };
        }
      }
    }

    _reportData = categoryStats.entries.map((entry) {
      return {
        'category': entry.key,
        'quantity_sold': entry.value['quantity'],
        'revenue': entry.value['revenue'],
        'transactions': entry.value['transactions'],
      };
    }).toList();

    // Sort by revenue descending
    _reportData.sort(
        (a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double));

    _reportSummary = {
      'total_categories': _reportData.length,
      'total_revenue': _reportData.fold(
          0.0, (sum, item) => sum + (item['revenue'] as double)),
    };
  }

  Future<void> _generateCashiersReport() async {
    final payments = await _firestore
        .collection('Payments')
        .where('payment_date',
            isGreaterThan: Timestamp.fromDate(_dateRange.start))
        .where('payment_date',
            isLessThan:
                Timestamp.fromDate(_dateRange.end.add(Duration(days: 1))))
        .get();

    Map<String, Map<String, dynamic>> cashierStats = {};

    for (final doc in payments.docs) {
      final data = doc.data();
      final cashier = data['cashier']?.toString() ?? 'Unknown';
      final amount = PaymentService.convertToDouble(data['paid_amount']);

      if (cashierStats.containsKey(cashier)) {
        cashierStats[cashier]!['amount'] += amount;
        cashierStats[cashier]!['transactions']++;
      } else {
        cashierStats[cashier] = {
          'amount': amount,
          'transactions': 1,
        };
      }
    }

    _reportData = cashierStats.entries.map((entry) {
      return {
        'cashier': entry.key,
        'total_amount': entry.value['amount'],
        'transactions': entry.value['transactions'],
        'average_transaction':
            entry.value['amount'] / entry.value['transactions'],
      };
    }).toList();

    // Sort by total amount descending
    _reportData.sort((a, b) =>
        (b['total_amount'] as double).compareTo(a['total_amount'] as double));

    _reportSummary = {
      'total_cashiers': _reportData.length,
      'total_amount': _reportData.fold(
          0.0, (sum, item) => sum + (item['total_amount'] as double)),
      'total_transactions': _reportData.fold(
          0, (sum, item) => sum + (item['transactions'] as int)),
    };
  }

  Future<void> _exportReport() async {
    setState(() => _isGenerating = true);

    try {
      if (UniversalPlatform.isWeb) {
        await _exportForWeb();
      } else {
        await _exportForMobileDesktop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report exported successfully!')),
      );
    } catch (e) {
      print('Export error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export report: ${e.toString()}')),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  // Web-specific export methods using package:web
  Future<void> _exportToPdfWeb() async {
    final pdf.Document document = pdf.Document();

    document.addPage(
      pdf.MultiPage(
        build: (context) => [
          pdf.Header(
            level: 0,
            child: pdf.Text(
              '${_reportTypes[_selectedReportType]} - ${_formatDate(_dateRange.start)} to ${_formatDate(_dateRange.end)}',
              style:
                  pdf.TextStyle(fontSize: 20, fontWeight: pdf.FontWeight.bold),
            ),
          ),
          pdf.SizedBox(height: 20),
          _buildPdfSummary(),
          pdf.SizedBox(height: 20),
          _buildPdfTable(),
        ],
      ),
    );

    final Uint8List pdfData = await document.save();
    _downloadFileWeb(
        pdfData,
        '${_selectedReportType}_report_${_formatDate(DateTime.now())}.pdf',
        'application/pdf');
  }

  Future<void> _exportToExcelWeb() async {
    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];

    if (_reportData.isNotEmpty) {
      final headers = _reportData.first.keys.toList();
      for (int i = 0; i < headers.length; i++) {
        sheet
            .getRangeByIndex(1, i + 1)
            .setText(headers[i].replaceAll('_', ' ').toUpperCase());
      }

      for (int row = 0; row < _reportData.length; row++) {
        for (int col = 0; col < headers.length; col++) {
          final value = _reportData[row][headers[col]];
          sheet.getRangeByIndex(row + 2, col + 1).setText(_formatValue(value));
        }
      }
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    _downloadFileWeb(
        Uint8List.fromList(bytes),
        '${_selectedReportType}_report_${_formatDate(DateTime.now())}.xlsx',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
  }

  Future<void> _exportToCsvWeb() async {
    if (_reportData.isEmpty) return;

    final headers = _reportData.first.keys.toList();
    final csvContent = StringBuffer();

    csvContent.writeln(headers
        .map((h) => '"${h.replaceAll('_', ' ').toUpperCase()}"')
        .join(','));

    for (final row in _reportData) {
      final values =
          headers.map((header) => '"${_formatValue(row[header])}"').join(',');
      csvContent.writeln(values);
    }

    final bytes = Uint8List.fromList(csvContent.toString().codeUnits);
    _downloadFileWeb(
        bytes,
        '${_selectedReportType}_report_${_formatDate(DateTime.now())}.csv',
        'text/csv');
  }

  void _downloadFileWeb(Uint8List bytes, String fileName, String mimeType) {
    // Create a Blob
    final blobParts = [bytes]; // Pass Uint8List directly as a list of BlobPart
    final blob = web.Blob(blobParts as JSArray<web.BlobPart>,
        web.BlobPropertyBag(type: mimeType));

    // Create an object URL
    final url = web.URL.createObjectURL(blob);

    // Create an anchor element
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = url;
    anchor.download = fileName;
    anchor.style.display = 'none';

    // Add to document and click
    web.document.body?.appendChild(anchor);
    anchor.click();

    // Clean up
    web.document.body?.removeChild(anchor);
    web.URL.revokeObjectURL(url);
  }

  Future<void> _exportForWeb() async {
    switch (_selectedFormat) {
      case 'pdf':
        await _exportToPdfWeb();
        break;
      case 'excel':
        await _exportToExcelWeb();
        break;
      case 'csv':
        await _exportToCsvWeb();
        break;
    }
  }

  Future<void> _exportForMobileDesktop() async {
    switch (_selectedFormat) {
      case 'pdf':
        await _exportToPdf();
        break;
      case 'excel':
        await _exportToExcel();
        break;
      case 'csv':
        await _exportToCsv();
        break;
    }
  }

  // Removed duplicate and unreferenced _exportReport method

  Future<void> _exportToPdf() async {
    final pdf.Document document = pdf.Document();

    // Add report header
    document.addPage(
      pdf.MultiPage(
        build: (context) => [
          pdf.Header(
            level: 0,
            child: pdf.Text(
              '${_reportTypes[_selectedReportType]} - ${_formatDate(_dateRange.start)} to ${_formatDate(_dateRange.end)}',
              style:
                  pdf.TextStyle(fontSize: 20, fontWeight: pdf.FontWeight.bold),
            ),
          ),
          pdf.SizedBox(height: 20),
          _buildPdfSummary(),
          pdf.SizedBox(height: 20),
          _buildPdfTable(),
        ],
      ),
    );

    // Save and share the PDF
    final Uint8List pdfData = await document.save();
    final Directory tempDir = await getTemporaryDirectory();
    final File file = File(
        '${tempDir.path}/report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(pdfData);

    // Fixed FileSaver usage
    await FileSaver.instance.saveAs(
      '${_selectedReportType}_report_${_formatDate(DateTime.now())}',
      pdfData,
      'pdf',
      MimeType.PDF,
    );
  }

  pdf.Widget _buildPdfSummary() {
    final summaryWidgets = <pdf.Widget>[];

    _reportSummary.forEach((key, value) {
      if (value is Map) {
        summaryWidgets.add(pdf.Text('$key:',
            style: pdf.TextStyle(fontWeight: pdf.FontWeight.bold)));
        value.forEach((subKey, subValue) {
          summaryWidgets.add(pdf.Text('  $subKey: ${_formatValue(subValue)}'));
        });
        summaryWidgets.add(pdf.SizedBox(height: 10));
      } else {
        summaryWidgets.add(pdf.Text('$key: ${_formatValue(value)}'));
      }
    });

    return pdf.Column(
        crossAxisAlignment: pdf.CrossAxisAlignment.start,
        children: summaryWidgets);
  }

  pdf.Widget _buildPdfTable() {
    if (_reportData.isEmpty) {
      return pdf.Text('No data available');
    }

    final headers = _reportData.first.keys.toList();
    final dataRows = _reportData
        .map((row) => pdf.TableRow(
              children: headers
                  .map((header) => pdf.Padding(
                        padding: pdf.EdgeInsets.all(4),
                        child: pdf.Text(_formatValue(row[header])),
                      ))
                  .toList(),
            ))
        .toList();

    return pdf.Table(
      border: pdf.TableBorder.all(),
      children: [
        pdf.TableRow(
          children: headers
              .map((header) => pdf.Padding(
                    padding: pdf.EdgeInsets.all(4),
                    child: pdf.Text(header.replaceAll('_', ' ').toUpperCase(),
                        style: pdf.TextStyle(fontWeight: pdf.FontWeight.bold)),
                  ))
              .toList(),
        ),
        ...dataRows,
      ],
    );
  }

  Future<void> _exportToExcel() async {
    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];

    // Add headers
    if (_reportData.isNotEmpty) {
      final headers = _reportData.first.keys.toList();
      for (int i = 0; i < headers.length; i++) {
        sheet
            .getRangeByIndex(1, i + 1)
            .setText(headers[i].replaceAll('_', ' ').toUpperCase());
      }

      // Add data
      for (int row = 0; row < _reportData.length; row++) {
        for (int col = 0; col < headers.length; col++) {
          final value = _reportData[row][headers[col]];
          sheet.getRangeByIndex(row + 2, col + 1).setText(_formatValue(value));
        }
      }
    }

    // Save the Excel file
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    // Fixed FileSaver usage
    await FileSaver.instance.saveAs(
      '${_selectedReportType}_report_${_formatDate(DateTime.now())}',
      Uint8List.fromList(bytes),
      'xlsx',
      MimeType.MICROSOFTEXCEL, // Changed to MimeType.MICROSOFTEXCEL
    );
  }

  Future<void> _exportToCsv() async {
    if (_reportData.isEmpty) return;

    final headers = _reportData.first.keys.toList();
    final csvContent = StringBuffer();

    // Add headers
    csvContent.writeln(headers
        .map((h) => '"${h.replaceAll('_', ' ').toUpperCase()}"')
        .join(','));

    // Add data
    for (final row in _reportData) {
      final values =
          headers.map((header) => '"${_formatValue(row[header])}"').join(',');
      csvContent.writeln(values);
    }

    final bytes = csvContent.toString().codeUnits;

    // Fixed FileSaver usage
    await FileSaver.instance.saveAs(
      '${_selectedReportType}_report_${_formatDate(DateTime.now())}',
      Uint8List.fromList(bytes),
      'csv',
      MimeType.OTHER, // Changed to MimeType.OTHER
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 365)),
      initialDateRange: _dateRange,
    );

    if (picked != null && picked != _dateRange) {
      setState(() => _dateRange = picked);
      _generateReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Row(
          children: [
            AppSidebar(currentScreen: 'reports'),
            Expanded(
              child: _buildReportContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportContent(BuildContext context) {
    return ResponsiveUtils.isMobile(context)
        ? _buildMobileLayout(context)
        : _buildDesktopLayout(context);
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(context),
          const SizedBox(height: 16),
          _buildFiltersSection(context),
          const SizedBox(height: 16),
          _buildActionButtons(context),
          const SizedBox(height: 24),
          _isGenerating ? _buildLoadingIndicator() : _buildReportPreview(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(context),
          const SizedBox(height: 24),
          _buildFiltersSection(context),
          const SizedBox(height: 16),
          _buildActionButtons(context),
          const SizedBox(height: 24),
          _isGenerating ? _buildLoadingIndicator() : _buildReportPreview(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('REPORTS', style: CustomTextStyles1.sectionHeader(context)),
        Text(
          'Last Updated: ${DateTime.now().toString()}',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: ResponsiveUtils.responsiveValue(
              context,
              mobile: 12,
              tablet: 14,
              desktop: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Report Filters', style: CustomTextStyles1.sectionHeader(context)),
        SizedBox(height: 12),
        _buildReportTypeDropdown(context),
        SizedBox(height: 12),
        _buildFormatDropdown(context),
        SizedBox(height: 12),
        _buildDateRangeSelector(context),
      ],
    );
  }

  Widget _buildReportTypeDropdown(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedReportType,
          items: _reportTypes.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedReportType = value!);
            _generateReport();
          },
        ),
      ),
    );
  }

  Widget _buildFormatDropdown(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFormat,
          items: _formatTypes.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedFormat = value!),
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDateRange(context),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_formatDate(_dateRange.start)} - ${_formatDate(_dateRange.end)}',
              style: TextStyle(fontSize: 16),
            ),
            Icon(Icons.calendar_today, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _isGenerating ? null : _generateReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF363753),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            child:
                Text('Refresh Report', style: TextStyle(color: Colors.white)),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isGenerating ? null : _exportReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF5CD2C6),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text('Export Report', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Generating report...'),
        ],
      ),
    );
  }

  Widget _buildReportPreview() {
    if (_reportData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('No data available for the selected criteria'),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Report Preview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        _buildSummaryCards(),
        SizedBox(height: 24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: _reportData.first.keys.map((key) {
              return DataColumn(
                label: Text(key.replaceAll('_', ' ').toUpperCase()),
              );
            }).toList(),
            rows: _reportData.take(10).map((data) {
              return DataRow(
                cells: data.values.map((value) {
                  return DataCell(Text(_formatValue(value)));
                }).toList(),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 16),
        Text('Showing ${_reportData.length} records',
            style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  String _formatDate(DateTime date) {
    // Format as yyyy-MM-dd
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatValue(dynamic value) {
    if (value == null) return '';
    if (value is double) return value.toStringAsFixed(2);
    if (value is DateTime) return _formatDate(value);
    return value.toString();
  }

  Widget _buildSummaryCards() {
    if (_reportSummary.isEmpty) return SizedBox();

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: _reportSummary.entries.map((entry) {
        if (entry.value is Map) {
          return SizedBox(); // Skip nested maps for summary cards
        }

        return Container(
          width: 200,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key.replaceAll('_', ' ').toUpperCase(),
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                _formatValue(entry.value),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
