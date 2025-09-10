// inventory_upload_screen.dart
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:io';
import 'dart:convert';
import '../services/inventory_service.dart';
import '../widgets/custom_text_styles1.dart';
import '../widgets/responsive_utils.dart';
import '../widgets/app_sidebar.dart';

class InventoryUploadScreen extends StatefulWidget {
  const InventoryUploadScreen({Key? key}) : super(key: key);

  @override
  _InventoryUploadScreenState createState() => _InventoryUploadScreenState();
}

class _InventoryUploadScreenState extends State<InventoryUploadScreen> {
  bool _isUploading = false;
  int _successfulImports = 0;
  int _failedImports = 0;
  List<Map<String, dynamic>> _csvData = [];
  List<String> _errors = [];
  String? _fileName;

  // Expected CSV columns
  final List<String> _expectedColumns = [
    'product',
    'code',
    'category',
    'price',
    'current_stock',
    'minimum_stock',
    'barcode'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Row(
          children: [
            if (!ResponsiveUtils.isMobile(context))
              AppSidebar(currentScreen: 'inventory'),
            Expanded(
              child: _buildContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.responsiveValue(
        context,
        mobile: 16,
        tablet: 20,
        desktop: 24,
      )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bulk Inventory Upload',
              style: CustomTextStyles1.sectionHeader(context)),
          SizedBox(height: 20),
          _buildInstructionsCard(),
          SizedBox(height: 20),
          _buildUploadSection(),
          SizedBox(height: 20),
          if (_csvData.isNotEmpty) _buildPreviewSection(),
          if (_errors.isNotEmpty) _buildErrorsSection(),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CSV File Requirements',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF363753),
                )),
            SizedBox(height: 12),
            Text(
                'Your CSV file should have the following columns in this exact order:',
                style: TextStyle(fontSize: 14)),
            SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _expectedColumns.map((column) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Text('• $column',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'monospace',
                      )),
                );
              }).toList(),
            ),
            SizedBox(height: 12),
            Text('Note: The first row should be the column headers.',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            SizedBox(height: 8),
            Text('Sample CSV format:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.grey[100],
              child: Text(
                'product,code,category,price,current_stock,minimum_stock,barcode\n'
                'Product Name,ITEM001,Category,19.99,100,10,1234567890123\n'
                'Another Product,ITEM002,Another Category,29.99,50,5,9876543210987',
                style: TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            if (_fileName != null) ...[
              Text('Selected file: $_fileName',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
            ],
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickCsvFile,
              icon: Icon(Icons.upload_file),
              label: Text(_isUploading ? 'Processing...' : 'Select CSV File'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5CD2C6),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
            SizedBox(height: 10),
            if (_csvData.isNotEmpty) ...[
              SizedBox(height: 20),
              Text('Found ${_csvData.length} products in the file',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isUploading ? null : _uploadToFirestore,
                child:
                    Text(_isUploading ? 'Uploading...' : 'Upload to Inventory'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF28A745),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preview (First 5 items)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF363753),
                )),
            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: _expectedColumns.map((column) {
                  return DataColumn(label: Text(column.toUpperCase()));
                }).toList(),
                rows: _csvData.take(5).map((item) {
                  return DataRow(
                    cells: _expectedColumns.map((column) {
                      return DataCell(Text(item[column]?.toString() ?? ''));
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorsSection() {
    return Card(
      color: Colors.red[50],
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Validation Errors',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                )),
            SizedBox(height: 10),
            ..._errors
                .map((error) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child:
                          Text('• $error', style: TextStyle(color: Colors.red)),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCsvFile() async {
    try {
      FilePickerResult? result;

      if (UniversalPlatform.isWeb) {
        // Web file picker
        final html.FileUploadInputElement uploadInput =
            html.FileUploadInputElement();
        uploadInput.accept = '.csv';
        uploadInput.click();

        await uploadInput.onChange.first;
        if (uploadInput.files!.isEmpty) return;

        final file = uploadInput.files![0];
        _fileName = file.name;
        final reader = html.FileReader();
        reader.readAsText(file);
        await reader.onLoad.first;

        final csvString = reader.result as String;
        _processCsvData(csvString);
      } else {
        // Mobile/Desktop file picker
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['csv'],
          allowMultiple: false,
        );

        if (result != null && result.files.single.path != null) {
          _fileName = result.files.single.name;
          final file = File(result.files.single.path!);
          final csvString = await file.readAsString();
          _processCsvData(csvString);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error reading file: ${e.toString()}')),
      );
    }
  }

  void _processCsvData(String csvString) {
    setState(() {
      _csvData.clear();
      _errors.clear();
      _isUploading = true;
    });

    try {
      final csvTable = CsvToListConverter().convert(csvString);

      if (csvTable.isEmpty) {
        setState(() {
          _errors.add('CSV file is empty');
          _isUploading = false;
        });
        return;
      }

      // Validate headers
      final headers =
          csvTable[0].map((e) => e.toString().toLowerCase().trim()).toList();
      if (!_validateHeaders(headers)) {
        setState(() {
          _errors.add('Invalid CSV format. Please check the column headers.');
          _isUploading = false;
        });
        return;
      }

      // Process data rows
      final List<Map<String, dynamic>> validData = [];
      final List<String> processingErrors = [];

      for (int i = 1; i < csvTable.length; i++) {
        final row = csvTable[i];
        if (row.length != _expectedColumns.length) {
          processingErrors.add('Row ${i + 1}: Incorrect number of columns');
          continue;
        }

        final productData = <String, dynamic>{};
        bool rowValid = true;

        for (int j = 0; j < _expectedColumns.length; j++) {
          final column = _expectedColumns[j];
          final value = row[j].toString().trim();

          // Validate required fields
          if (['product', 'code', 'category'].contains(column) &&
              value.isEmpty) {
            processingErrors.add('Row ${i + 1}: $column is required');
            rowValid = false;
            break;
          }

          // Validate numeric fields
          if (['price', 'current_stock', 'minimum_stock'].contains(column)) {
            final numValue = num.tryParse(value);
            if (numValue == null) {
              processingErrors.add('Row ${i + 1}: $column must be a number');
              rowValid = false;
              break;
            }
            productData[column] =
                column == 'price' ? numValue.toDouble() : numValue.toInt();
          } else {
            productData[column] = value;
          }
        }

        if (rowValid) {
          // Add default values and timestamps
          productData['status'] = _getStockStatus(
            productData['current_stock'] as int? ?? 0,
            productData['minimum_stock'] as int? ?? 1,
          );
          productData['created_at'] = FieldValue.serverTimestamp();
          productData['updated_at'] = FieldValue.serverTimestamp();

          validData.add(productData);
        }
      }

      setState(() {
        _csvData = validData;
        _errors = processingErrors;
        _isUploading = false;
      });
    } catch (e) {
      setState(() {
        _errors.add('Error parsing CSV: ${e.toString()}');
        _isUploading = false;
      });
    }
  }

  bool _validateHeaders(List<String> headers) {
    if (headers.length != _expectedColumns.length) return false;

    for (int i = 0; i < _expectedColumns.length; i++) {
      if (headers[i] != _expectedColumns[i]) return false;
    }

    return true;
  }

  String _getStockStatus(int currentStock, int minStock) {
    if (currentStock == 0) return 'Out of Stock';
    if (currentStock <= minStock) return 'Low Stock';
    return 'In Stock';
  }

  Future<void> _uploadToFirestore() async {
    if (_csvData.isEmpty) return;

    setState(() {
      _isUploading = true;
      _successfulImports = 0;
      _failedImports = 0;
    });

    final errors = <String>[];

    for (final productData in _csvData) {
      try {
        await InventoryService.addProduct(productData);
        _successfulImports++;
      } catch (e) {
        _failedImports++;
        errors
            .add('Failed to import ${productData['product']}: ${e.toString()}');
      }
    }

    setState(() {
      _isUploading = false;
      _errors = errors;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
            'Import completed: $_successfulImports successful, $_failedImports failed',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: _failedImports > 0 ? Colors.orange : Colors.green),
    );

    // Clear data after upload
    if (_successfulImports > 0) {
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _csvData.clear();
          _fileName = null;
        });
      });
    }
  }
}
