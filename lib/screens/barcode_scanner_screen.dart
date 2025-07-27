import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/barcode_service.dart';

class BarcodeScannerScreen extends StatefulWidget {
  final Function(String) onScan;
  final bool showCamera;
  final Function(String)? onError;

  const BarcodeScannerScreen({
    Key? key,
    required this.onScan,
    this.showCamera = true,
    this.onError,
  }) : super(key: key);

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  MobileScannerController? cameraController;
  bool _isTorchOn = false;
  bool _isCameraSwitched = false;
  bool _scanned = false;
  String? _errorMessage;
  bool _usbInitialized = false;

  @override
  void initState() {
    super.initState();

    if (widget.showCamera) {
      cameraController = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: false,
      );
    } else {
      // Initialize USB scanner after first frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeUsbScanner();
      });
    }
  }

  Future<void> _initializeUsbScanner() async {
    try {
      final initialized = await BarcodeService.initializeUsbScanner(
        context: context,
        onScan: (barcode) {
          if (mounted && !_scanned) {
            setState(() {
              _scanned = true;
            });
            widget.onScan(barcode);
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _errorMessage = error;
              _usbInitialized = false;
            });
            if (widget.onError != null) {
              widget.onError!(error);
            }
          }
        },
      );

      if (mounted) {
        setState(() {
          _usbInitialized = initialized;
          if (!initialized) {
            _errorMessage =
                'Failed to initialize USB scanner. Please check connection.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'USB scanner error: ${e.toString()}';
          _usbInitialized = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        actions: widget.showCamera && cameraController != null
            ? _buildCameraActions()
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _buildScannerContent(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerContent() {
    if (!widget.showCamera) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _usbInitialized ? Icons.usb : Icons.usb_off,
            size: 72,
            color: _usbInitialized ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 24),
          Text(
            _usbInitialized
                ? 'USB Scanner Ready\nScan a barcode...'
                : _errorMessage ?? 'Initializing USB scanner...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: _usbInitialized ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 24),
          if (!_usbInitialized)
            ElevatedButton(
              onPressed: _initializeUsbScanner,
              child: const Text('Retry Connection'),
            ),
        ],
      );
    }

    if (cameraController == null) {
      return const Center(child: Text('Camera not initialized'));
    }

    // Wrap in a Container with constraints to avoid layout issues
    return Container(
      constraints: const BoxConstraints.expand(),
      child: MobileScanner(
        controller: cameraController!,
        onDetect: (barcodes) {
          if (!_scanned && barcodes.barcodes.isNotEmpty) {
            final rawValue = barcodes.barcodes.first.rawValue;
            if (rawValue != null) {
              setState(() {
                _scanned = true;
              });
              widget.onScan(rawValue);
            }
          }
        },
      ),
    );
  }

  List<Widget> _buildCameraActions() {
    return [
      IconButton(
        icon: Icon(_isTorchOn ? Icons.flash_off : Icons.flash_on),
        onPressed: () {
          setState(() {
            _isTorchOn = !_isTorchOn;
            cameraController?.toggleTorch();
          });
        },
      ),
      IconButton(
        icon: Icon(_isCameraSwitched ? Icons.camera_rear : Icons.camera_front),
        onPressed: () {
          setState(() {
            _isCameraSwitched = !_isCameraSwitched;
            cameraController?.switchCamera();
          });
        },
      ),
    ];
  }

  @override
  void dispose() {
    cameraController?.dispose();
    if (!widget.showCamera) {
      BarcodeService.disposeUsbScanner();
    }
    super.dispose();
  }
}
