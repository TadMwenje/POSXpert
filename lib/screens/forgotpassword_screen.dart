// forgotpassword_screen.dart
import 'package:flutter/material.dart';
import '../widgets/custom_text_styles.dart'; // Import your text styles

class ForgotPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "assets/images/image1.png"), // Assuming you have image1.png
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Forgot Password',
                    style: CustomTextStyles.loginButtonTextStyle
                        .copyWith(color: const Color(0xFF363753)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Enter your email address, and we'll send you a link to reset your password.",
                    style:
                        CustomTextStyles.loginTextStyle.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Email Address',
                    style: CustomTextStyles.loginTextStyle,
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Enter your email address',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Implement send link functionality
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5CD2C6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                    ),
                    child: const Text(
                      'Send Link',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Go back to login screen
                    },
                    child: const Text(
                      'Back to Login',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
