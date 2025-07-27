import 'package:flutter/material.dart';
import 'responsive_utils.dart';

class CustomTextStyles1 {
  // App Bar Styles
  static TextStyle appBarTitle(BuildContext context) => TextStyle(
        color: Color(0xFF5CD2C6),
        fontSize: ResponsiveUtils.isMobile(context) ? 20 : 24,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
      );

  static TextStyle appBarAction(BuildContext context) => TextStyle(
        color: Color(0xFF363753),
        fontSize: ResponsiveUtils.isMobile(context) ? 14 : 16,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
      );

  // Search Bar
  static TextStyle searchText(BuildContext context) => TextStyle(
        color: Color(0xFF6B7280),
        fontSize: ResponsiveUtils.isMobile(context) ? 14 : 16,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
      );

  // Metric Cards
  static TextStyle metricTitle(BuildContext context) => TextStyle(
        color: Color(0xFF6B7280),
        fontSize: ResponsiveUtils.isMobile(context) ? 14 : 16,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w500,
      );

  static TextStyle metricValue(BuildContext context) => TextStyle(
        color: Color(0xFF111827),
        fontSize: ResponsiveUtils.isMobile(context) ? 24 : 32,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
      );

  static TextStyle metricChange(BuildContext context) => TextStyle(
        color: Color(0xFF10B981),
        fontSize: ResponsiveUtils.isMobile(context) ? 12 : 14,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w500,
      );

  // Section Headers
  static TextStyle sectionHeader(BuildContext context) => TextStyle(
        color: Color(0xFF111827),
        fontSize: ResponsiveUtils.isMobile(context) ? 16 : 20,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
      );

  // Table Styles
  static TextStyle tableHeader(BuildContext context) => TextStyle(
        color: Color(0xFF6B7280),
        fontSize: ResponsiveUtils.isMobile(context) ? 12 : 14,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
      );

  static TextStyle tableCell(BuildContext context) => TextStyle(
        color: Color(0xFF111827),
        fontSize: ResponsiveUtils.isMobile(context) ? 12 : 14,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
      );

  // Button Styles
  static TextStyle buttonText(BuildContext context) => TextStyle(
        color: Colors.white,
        fontSize: ResponsiveUtils.isMobile(context) ? 12 : 14,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
      );
}
