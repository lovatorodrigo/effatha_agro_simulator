import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/app_background.dart';
import './widgets/password_reset_form_widget.dart';
import './widgets/password_reset_success_widget.dart';

/// Password Reset Screen for secure password recovery
/// Provides email-based password reset with mobile-optimized workflow
class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  bool _isLoading = false;
  bool _isSuccess = false;
  bool _isResending = false;
  String? _errorMessage;
  String _submittedEmail = '';

  // Mock user data for demonstration
  final List<Map<String, dynamic>> _mockUsers = [
    {
      "email": "farmer@effatha.com",
      "name": "João Silva",
      "role": "Farm Manager"
    },
    {
      "email": "agronomist@effatha.com",
      "name": "Maria Santos",
      "role": "Agronomist"
    },
    {
      "email": "consultant@effatha.com",
      "name": "Carlos Rodriguez",
      "role": "Agricultural Consultant"
    },
    {"email": "demo@effatha.com", "name": "Demo User", "role": "Demo Account"},
  ];

  Future<void> _handlePasswordReset(String email) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Check if email exists in mock data
      final userExists = _mockUsers.any(
        (user) => (user["email"] as String).toLowerCase() == email.toLowerCase(),
      );

      if (!userExists) {
        setState(() {
          _errorMessage =
              'No account found with this email address. Please check your email or create a new account.';
          _isLoading = false;
        });
        return;
      }

      // Simulate successful password reset
      setState(() {
        _submittedEmail = email;
        _isSuccess = true;
        _isLoading = false;
      });

      // Provide haptic feedback on success
      HapticFeedback.lightImpact();
    } catch (_) {
      setState(() {
        _errorMessage =
            'Network error. Please check your connection and try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleResendEmail() async {
    setState(() => _isResending = true);

    try {
      // Simulate resend API call
      await Future.delayed(const Duration(seconds: 1));

      setState(() => _isResending = false);

      // Show success feedback
      HapticFeedback.lightImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reset link sent to $_submittedEmail'),
            backgroundColor: AppTheme.successLight,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (_) {
      setState(() => _isResending = false);
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login-screen');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBackground(
      assetPath: 'assets/images/bg_sim_soy.jpg',
      child: Scaffold(
        backgroundColor: Colors.transparent, // fundo fica por conta do AppBackground
        body: SafeArea(
          child: Column(
            children: [
              // App bar com botão voltar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _navigateToLogin,
                      icon: const CustomIconWidget(
                        iconName: 'arrow_back',
                        color: Colors.white,
                        size: 24,
                      ),
                      tooltip: 'Back to Sign In',
                      padding: EdgeInsets.all(3.w),
                    ),
                    Expanded(
                      child: Text(
                        'Password Reset',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.8),
                              offset: const Offset(0, 1),
                              blurRadius: 2.0,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 12.w), // balancear o espaço do botão voltar
                  ],
                ),
              ),

              // Conteúdo principal
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Column(
                    children: [
                      SizedBox(height: 8.h),

                      // Logo Effatha (container simples)
                      Container(
                        width: 30.w,
                        height: 15.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10.0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'EFFATHA',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryLight,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 6.h),

                      // Form ou sucesso
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _isSuccess
                            ? PasswordResetSuccessWidget(
                                key: const ValueKey('success'),
                                email: _submittedEmail,
                                onResendPressed: _handleResendEmail,
                                isResending: _isResending,
                              )
                            : PasswordResetFormWidget(
                                key: const ValueKey('form'),
                                onEmailSubmitted: _handlePasswordReset,
                                isLoading: _isLoading,
                                errorMessage: _errorMessage,
                              ),
                      ),
                      SizedBox(height: 4.h),

                      // Link para voltar ao login (quando ainda não houve sucesso)
                      if (!_isSuccess)
                        TextButton(
                          onPressed: _navigateToLogin,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 2.h,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CustomIconWidget(
                                iconName: 'arrow_back',
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Back to Sign In',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.8),
                                      offset: const Offset(0, 1),
                                      blurRadius: 2.0,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
