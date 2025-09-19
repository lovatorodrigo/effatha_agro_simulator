import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Password reset form widget with email input and validation
class PasswordResetFormWidget extends StatefulWidget {
  final Function(String) onEmailSubmitted;
  final bool isLoading;
  final String? errorMessage;

  const PasswordResetFormWidget({
    super.key,
    required this.onEmailSubmitted,
    required this.isLoading,
    this.errorMessage,
  });

  @override
  State<PasswordResetFormWidget> createState() =>
      _PasswordResetFormWidgetState();
}

class _PasswordResetFormWidgetState extends State<PasswordResetFormWidget> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isValidEmail = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateEmail);
    _emailController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    final isValid = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
    if (_isValidEmail != isValid) {
      setState(() {
        _isValidEmail = isValid;
      });
    }
  }

  String? _validateEmailField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() == true && _isValidEmail) {
      widget.onEmailSubmitted(_emailController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 90.w,
      constraints: BoxConstraints(maxWidth: 400),
      padding: EdgeInsets.all(6.w),
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
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              'Reset Password',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),

            // Description
            Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),

            // Email input field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              enabled: !widget.isLoading,
              validator: _validateEmailField,
              decoration: InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter your email address',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'email',
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                    size: 20,
                  ),
                ),
                suffixIcon: _emailController.text.isNotEmpty
                    ? Padding(
                        padding: EdgeInsets.all(3.w),
                        child: CustomIconWidget(
                          iconName: _isValidEmail ? 'check_circle' : 'error',
                          color: _isValidEmail
                              ? AppTheme.successLight
                              : AppTheme.errorLight,
                          size: 20,
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color:
                        (isDark ? AppTheme.dividerDark : AppTheme.dividerLight)
                            .withOpacity(0.5),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color:
                        (isDark ? AppTheme.dividerDark : AppTheme.dividerLight)
                            .withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color:
                        isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                    width: 2.0,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppTheme.errorDark : AppTheme.errorLight,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppTheme.errorDark : AppTheme.errorLight,
                    width: 2.0,
                  ),
                ),
                filled: true,
                fillColor:
                    isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              ),
              onFieldSubmitted: (_) => _handleSubmit(),
            ),

            // Error message
            if (widget.errorMessage != null) ...[
              SizedBox(height: 1.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: (isDark ? AppTheme.errorDark : AppTheme.errorLight)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (isDark ? AppTheme.errorDark : AppTheme.errorLight)
                        .withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'error_outline',
                      color: isDark ? AppTheme.errorDark : AppTheme.errorLight,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        widget.errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              isDark ? AppTheme.errorDark : AppTheme.errorLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 4.h),

            // Send reset link button
            SizedBox(
              height: 6.h,
              child: ElevatedButton(
                onPressed:
                    (_isValidEmail && !widget.isLoading) ? _handleSubmit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                  foregroundColor:
                      isDark ? AppTheme.onPrimaryDark : AppTheme.onPrimaryLight,
                  disabledBackgroundColor: (isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight)
                      .withOpacity(0.3),
                  elevation: widget.isLoading ? 0 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: widget.isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark
                                ? AppTheme.onPrimaryDark
                                : AppTheme.onPrimaryLight,
                          ),
                        ),
                      )
                    : Text(
                        'Send Reset Link',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
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
