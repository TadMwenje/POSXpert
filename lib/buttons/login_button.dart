import 'package:flutter/material.dart';
import '../widgets/custom_text_styles.dart';

class LoginButton extends StatelessWidget {
  final VoidCallback onPressed;

  const LoginButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        // ... your existing button styling ...
        child: Center(
          child: Text(
            'LOG IN',
            style: CustomTextStyles.loginButtonTextStyle,
          ),
        ),
      ),
    );
  }
}
