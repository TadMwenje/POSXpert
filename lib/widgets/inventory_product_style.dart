import 'package:flutter/material.dart';

class InventoryProductStyles {
  // Title Text Style
  static const TextStyle titleTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 28,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700,
    letterSpacing: -0.56,
  );

  // Subtitle Text Style
  static const TextStyle subtitleTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 24,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700,
    letterSpacing: -0.48,
  );

  // Label Text Style
  static const TextStyle labelTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 18,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700,
    letterSpacing: -0.36,
  );

  // Input Text Style
  static const TextStyle inputTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 16,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
    letterSpacing: -0.32,
  );

  // Button Text Style
  static const TextStyle buttonTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700,
    letterSpacing: -0.36,
  );

  // Cancel Button Style
  static ButtonStyle cancelButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFEE1D20),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
  );

  // Save Button Style
  static ButtonStyle saveButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF28A745),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
  );

  // Input Decoration
  static InputDecoration inputDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(width: 1),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );
}
