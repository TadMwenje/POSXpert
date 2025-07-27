import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class BarcodeService {
  static final BarcodeService _instance = BarcodeService._internal();
  factory BarcodeService() => _instance;
  BarcodeService._internal();

  static Function(String)? _onScanCallback;
  static Function(String)? _onErrorCallback;
  static bool _isInitialized = false;
  static String _buffer = '';
  static DateTime _lastInputTime = DateTime.now();
  static OverlayEntry? _overlayEntry;
  static FocusNode? _focusNode;

  // Add a pending message queue to avoid calling showSnackBar during build
  static String? _pendingErrorMessage;
  static BuildContext? _contextForErrors;

  static Future<bool> initializeUsbScanner({
    required BuildContext context,
    required Function(String) onScan,
    required Function(String) onError,
  }) async {
    try {
      if (_isInitialized) {
        disposeUsbScanner(); // Dispose previous instance first
      }

      _onScanCallback = onScan;
      _onErrorCallback = onError;
      _contextForErrors = context;
      _buffer = '';

      // Create invisible focus node for capturing keyboard input
      _focusNode = FocusNode();

      // Add keyboard listener to overlay
      _overlayEntry = OverlayEntry(
        builder: (context) => KeyboardListener(
          focusNode: _focusNode!,
          onKeyEvent: (keyEvent) {
            if (keyEvent is KeyDownEvent) {
              _handleKeyEvent(keyEvent);
            }
          },
          child: Container(width: 0, height: 0), // Invisible widget
        ),
      );

      // Use addPostFrameCallback to add the overlay after the current frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_contextForErrors != null && _contextForErrors!.mounted) {
          Overlay.of(_contextForErrors!).insert(_overlayEntry!);
          _focusNode!.requestFocus();
        }
      });

      _isInitialized = true;
      return true;
    } catch (e) {
      _onErrorCallback?.call('Error initializing scanner: ${e.toString()}');
      return false;
    }
  }

  // Rest of the methods remain the same
  static void _handleKeyEvent(KeyEvent event) {
    final now = DateTime.now();
    final timeSinceLastInput = now.difference(_lastInputTime);
    _lastInputTime = now;

    // If this is a termination character (Enter/Return)
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      if (_buffer.isNotEmpty) {
        // Process complete barcode
        _onScanCallback?.call(_buffer.trim());
        _buffer = '';
      }
    }
    // Reset buffer if time between inputs is too long (not a barcode scan)
    else if (timeSinceLastInput.inMilliseconds > 300) {
      _buffer = '';
      _addCharacterToBuffer(event);
    }
    // Otherwise, add character to buffer
    else {
      _addCharacterToBuffer(event);
    }
  }

  static void _addCharacterToBuffer(KeyEvent event) {
    final character = event.character;
    if (character != null && character.isNotEmpty) {
      _buffer += character;
    } else if (event.logicalKey.keyLabel.length == 1) {
      _buffer += event.logicalKey.keyLabel;
    }
  }

  static void disposeUsbScanner() {
    if (_overlayEntry != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      });
    }
    _focusNode?.dispose();
    _focusNode = null;
    _buffer = '';
    _onScanCallback = null;
    _onErrorCallback = null;
    _isInitialized = false;
    _contextForErrors = null;
  }
}
