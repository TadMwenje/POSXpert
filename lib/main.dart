import 'package:flutter/material.dart';
import 'widgets/splash_screen.dart'; // Import the SplashScreen
import 'screens/login_screen.dart';
import 'screens/smart_dashboard_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/signup_screen.dart'; // Import your SignupScreen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POSXpert',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Set this to the splash screen
      routes: {
        '/': (context) =>
            SplashScreen(), // Set SplashScreen as the initial route
        '/login': (context) => LoginScreen(), // Ensure this route matches
        '/dashboard': (context) => SmartDashboardScreen(),
        '/orders': (context) => OrdersScreen(),
        '/settings': (context) => SettingsScreen(),
        '/signup': (context) => SignupScreen(),
      },
    );
  }
}
