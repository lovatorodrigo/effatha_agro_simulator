import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LoginFormWidget extends StatefulWidget {
  final Function(String email, String password) onLogin;
  final bool isLoading;

  const LoginFormWidget({
    super.key,
    required this.onLogin,
    required this.isLoading,
  });

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid = _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _isValidEmail(_emailController.text);

    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!_isValidEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onLogin(_emailController.text.trim(), _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 85.w,
      constraints: BoxConstraints(maxWidth: 400),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email Input Field
            Container(
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight)
                    .withOpacity(0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (isDark ? AppTheme.dividerDark : AppTheme.dividerLight)
                      .withOpacity(0.2),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? AppTheme.shadowDark : AppTheme.shadowLight)
                        .withOpacity(0.1),
                    blurRadius: 10.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                enabled: !widget.isLoading,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimaryLight,
                ),
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'Enter your email',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CustomIconWidget(
                      iconName: 'email',
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight,
                      size: 24,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  labelStyle: theme.inputDecorationTheme.labelStyle,
                  hintStyle: theme.inputDecorationTheme.hintStyle,
                  errorStyle: theme.inputDecorationTheme.errorStyle?.copyWith(
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
                validator: _validateEmail,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
            ),

            SizedBox(height: 2.h),

            // Password Input Field
            Container(
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight)
                    .withOpacity(0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (isDark ? AppTheme.dividerDark : AppTheme.dividerLight)
                      .withOpacity(0.2),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? AppTheme.shadowDark : AppTheme.shadowLight)
                        .withOpacity(0.1),
                    blurRadius: 10.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                textInputAction: TextInputAction.done,
                enabled: !widget.isLoading,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimaryLight,
                ),
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CustomIconWidget(
                      iconName: 'lock',
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight,
                      size: 24,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: CustomIconWidget(
                      iconName:
                          _isPasswordVisible ? 'visibility_off' : 'visibility',
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight,
                      size: 24,
                    ),
                    onPressed: widget.isLoading
                        ? null
                        : () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                    padding: const EdgeInsets.all(16.0),
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  labelStyle: theme.inputDecorationTheme.labelStyle,
                  hintStyle: theme.inputDecorationTheme.hintStyle,
                  errorStyle: theme.inputDecorationTheme.errorStyle?.copyWith(
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
                validator: _validatePassword,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onFieldSubmitted: (_) => _isFormValid ? _handleLogin() : null,
              ),
            ),

            SizedBox(height: 1.h),

            // Forgot Password Link
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: widget.isLoading
                    ? null
                    : () {
                        Navigator.pushNamed(context, '/password-reset-screen');
                      },
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size(0, 6.h),
                ),
                child: Text(
                  'Forgot Password?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color:
                        isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            SizedBox(height: 2.h),

            // Sign In Button
            SizedBox(
              height: 7.h,
              child: ElevatedButton(
                onPressed:
                    (_isFormValid && !widget.isLoading) ? _handleLogin : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                  foregroundColor:
                      isDark ? AppTheme.onPrimaryDark : AppTheme.onPrimaryLight,
                  disabledBackgroundColor: (isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight)
                      .withOpacity(0.3),
                  elevation: _isFormValid ? 2.0 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: widget.isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark
                                ? AppTheme.onPrimaryDark
                                : AppTheme.onPrimaryLight,
                          ),
                        ),
                      )
                    : Text(
                        'Sign In',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
