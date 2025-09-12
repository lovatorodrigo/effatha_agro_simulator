import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RegistrationFooterWidget extends StatelessWidget {
  final VoidCallback onSignInTap;

  const RegistrationFooterWidget({
    super.key,
    required this.onSignInTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 90.w,
      constraints: BoxConstraints(maxWidth: 400),
      child: Column(
        children: [
          // Sign In Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account? ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
              ),
              GestureDetector(
                onTap: onSignInTap,
                child: Text(
                  'Sign In',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color:
                        isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),

          // Footer Information
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight)
                  .withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (isDark ? AppTheme.dividerDark : AppTheme.dividerLight)
                    .withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'security',
                      color:
                          isDark ? AppTheme.successDark : AppTheme.successLight,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Secure & Encrypted',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  'Your agricultural data is protected with enterprise-grade security',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),

          // Version and Copyright
          Text(
            '© 2025 Effatha Agro Simulator v1.0.0',
            style: theme.textTheme.bodySmall?.copyWith(
              color: (isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight)
                  .withOpacity(0.7),
              fontSize: 10.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
