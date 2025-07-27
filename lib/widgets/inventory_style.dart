import 'package:flutter/material.dart';

class InventoryStyles {
  static const TextStyle titleTextStyle = TextStyle(
    fontSize: 28,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );

  static const TextStyle menuTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle filterTextStyle = TextStyle(
    fontSize: 16,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700,
    color: Color(0xFF363753),
  );

  static const TextStyle tableHeaderTextStyle = TextStyle(
    fontSize: 16,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );

  static const TextStyle tableDataTextStyle = TextStyle(
    fontSize: 16,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );

  // Action Button Text Style
  static const TextStyle actionTextStyle = TextStyle(
    fontSize: 14,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w500,
    letterSpacing: -0.28,
  );

  // Error Text Style
  static const TextStyle errorTextStyle = TextStyle(
    color: Colors.red,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // Empty Text Style
  static const TextStyle emptyTextStyle = TextStyle(
    color: Colors.grey,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
}
