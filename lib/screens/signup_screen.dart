// screens/signup_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/auth_wrapper.dart';
import '../widgets/signup_style.dart';
import '../services/firebase_auth_service.dart';
import '../services/user_management_service.dart';
import 'smart_dashboard_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _isAgreed = false;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUpUser(BuildContext context) async {
    if (_formKey.currentState!.validate() && _isAgreed) {
      setState(() => _isLoading = true);
      try {
        // 1. First create auth user
        final userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // 2. Check if first user
        final isFirstUser = await _checkIfFirstUser();
        final role = isFirstUser ? 'admin' : 'user';

        // 3. Create user document directly (bypass UserManagementService)
        await FirebaseFirestore.instance
            .collection('Employee')
            .doc(userCredential.user!.uid)
            .set({
          'f_name': _nameController.text.split(' ').first,
          'l_name': _nameController.text.split(' ').length > 1
              ? _nameController.text.split(' ').sublist(1).join(' ')
              : '',
          'email': _emailController.text,
          'phone': _phoneController.text,
          'role': role,
          'username': _emailController.text.split('@').first,
          'state': 'active',
          'created_at': FieldValue.serverTimestamp(),
        });

        // 4. Mark first user if needed
        if (isFirstUser) {
          await FirebaseFirestore.instance
              .collection('Employee')
              .doc('__firstUser__')
              .set({'exists': true});
        }

        // 5. Navigate to dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AuthWrapper(child: SmartDashboardScreen()),
          ),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Registration failed. Please try again.';
        if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'An account already exists for that email.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'The email address is not valid.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    } else if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please agree to the terms and conditions')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/image1.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 600,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sign Up', style: SignupStyles.signUpTitle),
                    SizedBox(height: 10),
                    Text('Enter your user name and password',
                        style: SignupStyles.labelText),
                    SizedBox(height: 20),
                    _buildTextFormField('Full Name', _nameController,
                        validator: _validateName),
                    _buildTextFormField('Company Name', _companyController),
                    _buildTextFormField('Phone Number', _phoneController,
                        validator: _validatePhone),
                    _buildTextFormField('Email address', _emailController,
                        validator: _validateEmail),
                    _buildTextFormField('Create Password', _passwordController,
                        obscureText: true, validator: _validatePassword),
                    _buildTextFormField(
                        'Confirm Password', _confirmPasswordController,
                        obscureText: true, validator: _validateConfirmPassword),
                    SizedBox(height: 20),
                    _buildAgreementCheckbox(),
                    SizedBox(height: 20),
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : _buildSignUpButton(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(String label, TextEditingController controller,
      {bool obscureText = false, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
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

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
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

  Widget _buildSignUpButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0x75655CD2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onPressed: () async {
          if (_formKey.currentState!.validate() && _isAgreed) {
            setState(() => _isLoading = true);
            try {
              // Check if this is the first user (should be admin)
              final isFirstUser = await _checkIfFirstUser();
              final role = isFirstUser ? 'admin' : 'user';

              // Create user with UserManagementService
              final userService = UserManagementService();
              await userService.addUser(
                email: _emailController.text,
                password: _passwordController.text,
                fullName: _nameController.text,
                phone: _phoneController.text,
                role: role,
                username: _emailController.text.split('@').first,
                isActive: true,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Registration successful!')),
              );

              // Navigate to dashboard after successful registration
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AuthWrapper(child: SmartDashboardScreen())),
              );
            } on FirebaseAuthException catch (e) {
              String errorMessage = 'Registration failed. Please try again.';
              if (e.code == 'weak-password') {
                errorMessage = 'The password provided is too weak.';
              } else if (e.code == 'email-already-in-use') {
                errorMessage = 'An account already exists for that email.';
              } else if (e.code == 'invalid-email') {
                errorMessage = 'The email address is not valid.';
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(errorMessage)),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${e.toString()}')),
              );
            } finally {
              setState(() => _isLoading = false);
            }
          } else if (!_isAgreed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Please agree to the terms and conditions')),
            );
          }
        },
        child: Text('Sign Up', style: SignupStyles.buttonText),
      ),
    );
  }

// Removed duplicate _signUpUser method to resolve the conflict.

  Future<bool> _isFirstUser() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Employee')
          .doc('__firstUser__')
          .get();
      return !snapshot.exists;
    } catch (e) {
      return true; // If error, assume first user
    }
  }

// Add this helper method
  Future<bool> _checkIfFirstUser() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Employee')
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();
      return snapshot.docs.isEmpty;
    } catch (e) {
      return true; // If error, assume first user
    }
  }
}
