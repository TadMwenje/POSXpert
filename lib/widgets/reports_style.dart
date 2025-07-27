// reports_style.dart
import 'package:flutter/material.dart';
import '../widgets/responsive_utils.dart';

class ReportsStyles {
  static TextStyle headerTextStyle(BuildContext context) => TextStyle(
        color: Color(0xFF363753),
        fontSize: ResponsiveUtils.responsiveValue(context,
            mobile: 30, tablet: 40, desktop: 48),
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
        letterSpacing: -0.48,
      );

  static TextStyle sectionHeaderStyle(BuildContext context) => TextStyle(
        color: Color(0xFF363753),
        fontSize: ResponsiveUtils.responsiveValue(context,
            mobile: 24, tablet: 30, desktop: 36),
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
        letterSpacing: -0.36,
      );

  static TextStyle dropdownTextStyle(BuildContext context) => TextStyle(
        color: Colors.black,
        fontSize: ResponsiveUtils.responsiveValue(context,
            mobile: 20, tablet: 28, desktop: 36),
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
        letterSpacing: -0.36,
      );

  static TextStyle buttonTextStyle(BuildContext context) => TextStyle(
        fontSize: ResponsiveUtils.responsiveValue(context,
            mobile: 20, tablet: 28, desktop: 36),
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
        letterSpacing: -0.36,
      );

  static TextStyle tableHeaderStyle(BuildContext context) => TextStyle(
        color: Color(0xFF363753),
        fontSize: ResponsiveUtils.responsiveValue(context,
            mobile: 18, tablet: 24, desktop: 32),
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
        letterSpacing: -0.32,
      );

  static TextStyle tableContentStyle(BuildContext context) => TextStyle(
        color: Color(0xFF363753),
        fontSize: ResponsiveUtils.responsiveValue(context,
            mobile: 16, tablet: 22, desktop: 32),
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
        letterSpacing: -0.32,
      );

  static TextStyle menuTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 36,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700,
    letterSpacing: -0.36,
  );

  static TextStyle selectedMenuTextStyle = TextStyle(
    color: Color(0xFF5CD2C6),
    fontSize: 36,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700,
    letterSpacing: -0.36,
  );

  static TextStyle lastUpdatedTextStyle(BuildContext context) => TextStyle(
        color: Colors.black,
        fontSize: ResponsiveUtils.responsiveValue(context,
            mobile: 16, tablet: 24, desktop: 36),
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
        letterSpacing: -0.36,
      );
}
