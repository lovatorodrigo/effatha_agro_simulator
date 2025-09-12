import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/login_background_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/login_header_widget.dart';
import './widgets/social_login_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  // Mock credentials for demonstration
  final Map<String, String> _mockCredentials = {
    'admin@effatha.com': 'admin123',
    'farmer@effatha.com': 'farmer123',
    'demo@effatha.com': 'demo123',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginBackgroundWidget(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 100.h,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // Header Section
                  const LoginHeaderWidget(),

                  // Form Section
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Error Message
                          if (_errorMessage != null) ...[
                            Container(
                              width: 85.w,
                              constraints: BoxConstraints(maxWidth: 400),
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.errorLight.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.errorLight
                                      .withOpacity(0.3),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'error_outline',
                                    color: AppTheme.errorLight,
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppTheme.errorLight,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Login Form
                          LoginFormWidget(
                            onLogin: _handleEmailLogin,
                            isLoading: _isLoading,
                          ),

                          SizedBox(height: 3.h),

                          // Social Login Options
                          SocialLoginWidget(
                            onGoogleSignIn: _handleGoogleSignIn,
                            onAppleSignIn: _handleAppleSignIn,
                            isLoading: _isLoading,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Spacing
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleEmailLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1500));

      // Check mock credentials
      if (_mockCredentials.containsKey(email.toLowerCase()) &&
          _mockCredentials[email.toLowerCase()] == password) {
        // Success - trigger haptic feedback
        HapticFeedback.lightImpact();

        // Navigate to dashboard
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/simulation-dashboard');
        }
      } else {
        // Invalid credentials
        setState(() {
          _errorMessage =
              'Invalid email or password. Please check your credentials and try again.';
        });
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      // Network or other error
      setState(() {
        _errorMessage =
            'Unable to sign in. Please check your internet connection and try again.';
      });
      HapticFeedback.mediumImpact();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulate Google Sign-In process
      await Future.delayed(const Duration(milliseconds: 2000));

      // Success - trigger haptic feedback
      HapticFeedback.lightImpact();

      // Navigate to dashboard
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/simulation-dashboard');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Google Sign-In failed. Please try again.';
      });
      HapticFeedback.mediumImpact();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulate Apple Sign-In process
      await Future.delayed(const Duration(milliseconds: 2000));

      // Success - trigger haptic feedback
      HapticFeedback.lightImpact();

      // Navigate to dashboard
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/simulation-dashboard');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Apple Sign-In failed. Please try again.';
      });
      HapticFeedback.mediumImpact();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
