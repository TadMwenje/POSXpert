import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_manager.dart';
import '../screens/login_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/inventory_screen.dart';
import '../screens/smart_dashboard_screen.dart';

class AuthWrapper extends StatefulWidget {
  final Widget child;

  const AuthWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final authManager = Provider.of<AuthManager>(context, listen: false);
    await authManager.initializeUser();

    if (mounted) {
      setState(() {
        _isCheckingAuth = false;
      });
    }
  }

  bool _hasAccessToScreen(Widget screen, String? userRole) {
    if (userRole == 'admin') return true;

    final screenType = screen.runtimeType.toString();

    // Cashier can only access orders and payment screens
    if (userRole == 'cashier') {
      return screenType.contains('Orders') ||
          screenType.contains('Payment') ||
          screenType.contains('Receipt');
    }

    // Inventory can access inventory and reports screens
    if (userRole == 'inventory') {
      return screenType.contains('Inventory') ||
          screenType.contains('Reports') ||
          screenType.contains('SmartDashboard');
    }

    return false;
  }

  Widget _getDefaultScreenForRole(String? userRole) {
    switch (userRole) {
      case 'cashier':
        return OrdersScreen();
      case 'inventory':
        return InventoryScreen();
      case 'admin':
      default:
        return SmartDashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authManager = Provider.of<AuthManager>(context);

    if (_isCheckingAuth) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If not authenticated, redirect to login
    if (!authManager.isAuthenticated) {
      return LoginScreen();
    }

    // If there's an authentication error
    if (authManager.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error: ${authManager.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await authManager.signOut();
                },
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      );
    }

    // Check if user has access to the requested screen
    if (!_hasAccessToScreen(widget.child, authManager.userRole)) {
      // Use Future.microtask to schedule the navigation after the current build
      Future.microtask(() {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) =>
                    _getDefaultScreenForRole(authManager.userRole)),
          );
        }
      });

      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text('Redirecting to ${authManager.userRole} dashboard...'),
            ],
          ),
        ),
      );
    }

    // User is authenticated and has access, show the protected screen
    return widget.child;
  }
}
