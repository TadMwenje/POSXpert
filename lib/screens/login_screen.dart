import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/auth_wrapper.dart';
import '../widgets/custom_text_styles.dart';
import '../services/auth_manager.dart';
import 'forgotpassword_screen.dart';
import 'signup_screen.dart';
import 'smart_dashboard_screen.dart';
import 'orders_screen.dart';
import 'inventory_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
            child: SingleChildScrollView(
              child: Container(
                width: 600,
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('LOG IN',
                          style: CustomTextStyles.loginButtonTextStyle
                              .copyWith(color: Color(0x75655CD2))),
                      SizedBox(height: 10),
                      Text('Enter your user name and password',
                          style: CustomTextStyles.loginTextStyle
                              .copyWith(color: Color(0x75655CD2))),
                      SizedBox(height: 20),
                      Text('Email address',
                          style: CustomTextStyles.loginTextStyle),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text('Password', style: CustomTextStyles.loginTextStyle),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                          ),
                          Text('Remember Me',
                              style: CustomTextStyles.rememberMeTextStyle),
                        ],
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0x75655CD2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: _isLoading ? null : _handleLogin,
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text('LOG IN',
                                  style: CustomTextStyles.loginButtonTextStyle),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ForgotPasswordScreen()),
                              );
                            },
                            child: Text('Forgot Password',
                                style:
                                    CustomTextStyles.forgotPasswordTextStyle),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignupScreen()),
                              );
                            },
                            child: Text('Sign Up',
                                style:
                                    CustomTextStyles.forgotPasswordTextStyle),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      if (mounted) {
        setState(() => _isLoading = true);
      }

      final authManager = Provider.of<AuthManager>(context, listen: false);

      try {
        final success = await authManager.signIn(_emailController.text.trim(),
            _passwordController.text.trim(), context);

        if (success && mounted) {
          // Navigate to appropriate screen based on role
          final userRole = authManager.userRole;
          Widget targetScreen = SmartDashboardScreen();

          if (userRole == 'cashier') {
            targetScreen = OrdersScreen();
          } else if (userRole == 'inventory') {
            targetScreen = InventoryScreen();
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AuthWrapper(child: targetScreen),
            ),
          );
        } else if (mounted && authManager.error != null) {
          // Show error message from AuthManager
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authManager.error!)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}
