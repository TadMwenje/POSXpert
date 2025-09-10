import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'widgets/splash_screen.dart';
import 'widgets/auth_wrapper.dart';
import 'screens/login_screen.dart';
import 'screens/smart_dashboard_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/inventory_view.dart';
import 'screens/inventory_edit.dart';
import 'screens/forgotpassword_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/inventory_product_screen.dart';
import 'screens/logout_screen.dart';
import 'screens/barcode_scanner_screen.dart';
import 'screens/useradd_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/receipt_screen_pdf.dart';
import 'screens/email_verification_screen.dart';
import 'screens/inventory_upload_screen.dart';
import 'models/user_data.dart';
import 'services/auth_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable Provider type checking to prevent the error with UserData
  Provider.debugCheckInvalidValueType = null;

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        // UserData provider
        Provider<UserData>(
          create: (_) => UserData.placeholder(),
        ),
        // AuthManager provider
        ChangeNotifierProvider<AuthManager>(
          create: (_) => AuthManager(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POSXpert',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        // Public routes (no auth required)
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/forgotpassword': (context) => ForgotPasswordScreen(),

        // Protected routes (wrapped with AuthWrapper)
        '/dashboard': (context) => AuthWrapper(
              child: SmartDashboardScreen(),
            ),
        '/orders': (context) => AuthWrapper(
              child: OrdersScreen(),
            ),
        '/payment': (context) => AuthWrapper(
              child: PaymentScreen(
                totalAmount:
                    ModalRoute.of(context)!.settings.arguments as double,
                items: [],
                orderId: '',
              ),
            ),
        '/receipt': (context) => AuthWrapper(
              child: ReceiptPdfScreen(
                paymentId: ModalRoute.of(context)!.settings.arguments as String,
              ),
            ),
        '/settings': (context) => AuthWrapper(
              child: SettingsScreen(),
            ),
        '/useradd': (context) => AuthWrapper(
              child: UserAddScreen(),
            ),
        '/verify-email': (context) => EmailVerificationScreen(),
        '/reports': (context) => AuthWrapper(
              child: ReportsScreen(),
            ),
        '/inventory': (context) => AuthWrapper(
              child: const InventoryScreen(),
            ),
        '/inventory_view': (context) => AuthWrapper(
              child: InventoryViewScreen(
                productData: ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>,
              ),
            ),
        '/inventory_edit': (context) => AuthWrapper(
              child: InventoryEditScreen(
                productData: ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>,
              ),
            ),
        '/inventory_product': (context) => AuthWrapper(
              child: const InventoryProductScreen(),
            ),
        '/logout': (context) => AuthWrapper(
              child: const LogoutScreen(),
            ),
        '/inventory_upload': (context) => AuthWrapper(
              child: const InventoryUploadScreen(),
            ),
        '/barcode_scanner': (context) => AuthWrapper(
              child: BarcodeScannerScreen(
                onScan: (barcode) {},
                showCamera: ModalRoute.of(context)!.settings.arguments as bool,
              ),
            ),
      },
      debugShowCheckedModeBanner: false,
      // Add navigator observer for role-based routing
      navigatorObservers: [RoleAwareNavigatorObserver()],
    );
  }
}

// Navigator observer for role-based access control
class RoleAwareNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    _checkRouteAccess(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (newRoute != null) {
      _checkRouteAccess(newRoute);
    }
  }

  void _checkRouteAccess(Route route) async {
    final context = navigator?.context;
    if (context == null) return;

    final authManager = Provider.of<AuthManager>(context, listen: false);

    if (!authManager.isAuthenticated) return;

    final routeName = route.settings.name;
    final userRole = authManager.userRole;

    // Define accessible routes for each role
    final accessibleRoutes = {
      'admin': [
        '/dashboard',
        '/orders',
        '/inventory',
        '/reports',
        '/settings',
        '/useradd',
        '/inventory_view',
        '/inventory_edit',
        '/inventory_product',
        '/inventory_upload',
        '/barcode_scanner',
        '/payment',
        '/receipt'
      ],
      'inventory': [
        '/dashboard',
        '/inventory',
        '/reports',
        '/inventory_view',
        '/inventory_edit',
        '/inventory_product',
        '/inventory_upload',
        '/barcode_scanner'
      ],
      'cashier': ['/dashboard', '/orders', '/payment', '/receipt'],
    };

    if (routeName != null &&
        !(accessibleRoutes[userRole]?.contains(routeName) ?? false)) {
      // Redirect to appropriate screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        String redirectRoute = '/dashboard';
        if (userRole == 'cashier') redirectRoute = '/orders';
        if (userRole == 'inventory') redirectRoute = '/inventory';

        Navigator.of(context).pushReplacementNamed(redirectRoute);
      });
    }
  }
}

// Helper extension for route checking
extension RouteExtension on Widget {
  String get routeName {
    return runtimeType.toString();
  }
}
