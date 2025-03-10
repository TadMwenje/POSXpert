import 'package:flutter/material.dart';
import '../widgets/custom_text_styles.dart';
import '../buttons/login_button.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/image1.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(
                    0.8), // Add a slight white background for better readability
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LOG IN',
                    style: CustomTextStyles.loginButtonTextStyle
                        .copyWith(color: Color(0x75655CD2)),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Enter your user name and password',
                    style: CustomTextStyles.loginTextStyle
                        .copyWith(color: Color(0x75655CD2)),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'User name / email',
                    style: CustomTextStyles.loginTextStyle,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter your username or email',
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Password',
                    style: CustomTextStyles.loginTextStyle,
                  ),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(value: false, onChanged: (bool? value) {}),
                      Text(
                        'Remember Me',
                        style: CustomTextStyles.rememberMeTextStyle,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  LoginButton(),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Navigate to Forgot Password screen (implement as needed)
                        },
                        child: Text(
                          'Forgot Password',
                          style: CustomTextStyles.forgotPasswordTextStyle,
                        ),
                      ),
                      SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                              context, '/signup'); // Navigate to SignupScreen
                        },
                        child: Text(
                          'Sign Up',
                          style: CustomTextStyles.forgotPasswordTextStyle,
                        ),
                      ),
                    ],
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
