import 'package:flutter/material.dart';
import '../widgets/signup_style.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _isAgreed = false; // Checkbox state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/image1.png"), // Background image
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            width: 600, // Adjust width for better centering
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color:
                  Colors.white.withOpacity(0.8), // Slightly opaque background
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 5,
                  blurRadius: 15,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sign Up',
                  style: SignupStyles.signUpTitle,
                ),
                SizedBox(height: 10),
                Text(
                  'Enter your user name and password',
                  style: SignupStyles.labelText,
                ),
                SizedBox(height: 20),
                _buildInputField('Full Name'),
                _buildInputField('Company Name'),
                _buildInputField('Phone Number'),
                _buildInputField('Email address'),
                _buildInputField('Create Password'),
                _buildInputField('Confirm Password'),
                SizedBox(height: 20),
                _buildAgreementCheckbox(),
                SizedBox(height: 20),
                _buildSignUpButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(0xFF363753)),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildAgreementCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _isAgreed,
          onChanged: (value) {
            setState(() {
              _isAgreed = value ?? false;
            });
          },
        ),
        Expanded(
          child: Text(
            'I agree to the Terms and Conditions and privacy policy',
            style: SignupStyles.agreementText,
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Color(0x75655CD2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Center(
        child: Text(
          'Sign Up',
          style: SignupStyles.buttonText,
        ),
      ),
    );
  }
}
