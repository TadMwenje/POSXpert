import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Existing methods...
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static double responsiveValue(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  // New responsive text style helper
  static TextStyle responsiveTextStyle(
    BuildContext context, {
    required TextStyle mobile,
    required TextStyle tablet,
    required TextStyle desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  // New responsive padding helper
  static EdgeInsets responsivePadding(
    BuildContext context, {
    required EdgeInsets mobile,
    required EdgeInsets tablet,
    required EdgeInsets desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }
}
