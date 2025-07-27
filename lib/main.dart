import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'widgets/splash_screen.dart';
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
import 'models/user_data.dart';
import 'services/auth_manager.dart';
import 'widgets/auth_wrapper.dart';
import 'screens/email_verification_screen.dart';

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
        // Keep your existing UserData provider
        Provider<UserData>(
          create: (_) => UserData.placeholder(),
        ),
        // Add the AuthManager which handles authentication and updates UserData
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
              key: const ValueKey('dashboard'),
            ),
        '/orders': (context) => AuthWrapper(
              child: OrdersScreen(),
              key: const ValueKey('orders'),
            ),
        '/settings': (context) => AuthWrapper(
              child: SettingsScreen(),
              key: const ValueKey('settings'),
            ),
        '/useradd': (context) => AuthWrapper(
              child: UserAddScreen(),
              key: const ValueKey('useradd'),
            ),
        '/verify-email': (context) => EmailVerificationScreen(),
        '/reports': (context) => AuthWrapper(
              child: ReportsScreen(),
              key: const ValueKey('reports'),
            ),
        '/inventory': (context) => AuthWrapper(
              child: const InventoryScreen(),
              key: const ValueKey('inventory'),
            ),
        '/inventory_view': (context) => AuthWrapper(
              child: InventoryViewScreen(
                productData: ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>,
              ),
              key: const ValueKey('inventory_view'),
            ),
        '/inventory_edit': (context) => AuthWrapper(
              child: InventoryEditScreen(
                productData: ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>,
              ),
              key: const ValueKey('inventory_edit'),
            ),
        '/inventory_product': (context) => AuthWrapper(
              child: const InventoryProductScreen(),
              key: const ValueKey('inventory_product'),
            ),
        '/logout': (context) => AuthWrapper(
              child: const LogoutScreen(),
              key: const ValueKey('logout'),
            ),
        '/barcode_scanner': (context) => AuthWrapper(
              child: BarcodeScannerScreen(
                onScan: (barcode) {}, // Will be overridden when navigated to
                showCamera: ModalRoute.of(context)!.settings.arguments as bool,
              ),
              key: const ValueKey('barcode_scanner'),
            ),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
