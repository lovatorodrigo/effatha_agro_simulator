import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Success state widget for password reset confirmation
class PasswordResetSuccessWidget extends StatefulWidget {
  final String email;
  final VoidCallback onResendPressed;
  final bool isResending;

  const PasswordResetSuccessWidget({
    super.key,
    required this.email,
    required this.onResendPressed,
    required this.isResending,
  });

  @override
  State<PasswordResetSuccessWidget> createState() =>
      _PasswordResetSuccessWidgetState();
}

class _PasswordResetSuccessWidgetState
    extends State<PasswordResetSuccessWidget> {
  int _countdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    setState(() {
      _countdown = 60;
      _canResend = false;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _countdown--;
        });
        if (_countdown <= 0) {
          setState(() {
            _canResend = true;
          });
          return false;
        }
        return true;
      }
      return false;
    });
  }

  void _handleResend() {
    if (_canResend && !widget.isResending) {
      widget.onResendPressed();
      _startCountdown();
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success icon
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: AppTheme.successLight.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.successLight.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.successLight,
                size: 10.w,
              ),
            ),
          ),
          SizedBox(height: 3.h),

          // Success title
          Text(
            'Check Your Email',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color:
                  isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),

          // Success message
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
                height: 1.4,
              ),
              children: [
                const TextSpan(
                  text: 'We\'ve sent a password reset link to\n',
                ),
                TextSpan(
                  text: widget.email,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color:
                        isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),

          // Instructions
          Text(
            'Please check your inbox and spam folder. Click the link in the email to reset your password.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),

          // Resend section
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color:
                  (isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight)
                      .withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (isDark ? AppTheme.dividerDark : AppTheme.dividerLight)
                    .withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Didn\'t receive the email?',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                  ),
                ),
                SizedBox(height: 2.h),

                // Resend button or countdown
                if (_canResend && !widget.isResending)
                  TextButton(
                    onPressed: _handleResend,
                    style: TextButton.styleFrom(
                      foregroundColor:
                          isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    ),
                    child: Text(
                      'Resend Email',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else if (widget.isResending)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark
                                ? AppTheme.primaryDark
                                : AppTheme.primaryLight,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Sending...',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    'Resend available in ${_countdown}s',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
