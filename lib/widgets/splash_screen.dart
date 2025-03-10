import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/login_screen.dart'; // Import the LoginScreen

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to LoginScreen after a delay
    Future.delayed(Duration(seconds: 3), () {
      // Reduced to 3 seconds for quicker testing
      Navigator.of(context).pushReplacementNamed('/login'); // Use named route
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFF363753), // Background color
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/pos.png'), // Central logo
              SizedBox(height: 20), // Space between logo and loader
              CircularProgressIndicator(
                value: null, // Indeterminate progress indicator
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.7)), // Faint color
              ),
            ],
          ),
        ),
      ),
    );
  }
}
