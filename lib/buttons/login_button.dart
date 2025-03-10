import 'package:flutter/material.dart';
import '../widgets/custom_text_styles.dart';

class LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, '/dashboard');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0x75655CD2), // Correct parameter
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        'LOG IN',
        style: CustomTextStyles.loginButtonTextStyle,
      ),
    );
  }
}
