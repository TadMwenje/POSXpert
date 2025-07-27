import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isVerified = false;
  String? _error;
  int _resendCooldown = 30;
  bool _canResend = true;

  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
    _startResendTimer();
  }

  Future<void> _checkVerificationStatus() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = _authService.currentUser;
      if (user != null) {
        await user.reload();
        if (user.emailVerified) {
          setState(() => _isVerified = true);
          await Future.delayed(Duration(seconds: 2));
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        }
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendVerification() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _canResend = false;
      _resendCooldown = 30;
    });

    try {
      await _authService.verifyEmail();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification email resent!')),
      );
      _startResendTimer();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startResendTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
        _startResendTimer();
      } else {
        setState(() => _canResend = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.email_outlined,
                size: 80,
                color: Colors.blue,
              ),
              SizedBox(height: 20),
              Text(
                'Verify Your Email',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'We\'ve sent a verification link to your email address. '
                'Please check your inbox and click the link to verify your account.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 30),
              if (_isLoading)
                CircularProgressIndicator()
              else if (_isVerified)
                Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 50),
                    SizedBox(height: 20),
                    Text('Email Verified! Redirecting...'),
                  ],
                )
              else
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _canResend ? _resendVerification : null,
                      child: Text(_canResend
                          ? 'Resend Verification Email'
                          : 'Resend in $_resendCooldown seconds'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _checkVerificationStatus,
                      child: Text('I\'ve Verified My Email'),
                    ),
                  ],
                ),
              if (_error != null) ...[
                SizedBox(height: 20),
                Text(
                  _error!,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
