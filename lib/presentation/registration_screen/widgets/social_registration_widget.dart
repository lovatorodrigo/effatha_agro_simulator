import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SocialRegistrationWidget extends StatelessWidget {
  final VoidCallback onGoogleSignUp;
  final VoidCallback? onAppleSignUp;
  final bool isLoading;

  const SocialRegistrationWidget({
    super.key,
    required this.onGoogleSignUp,
    this.onAppleSignUp,
    required this.isLoading,
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
          // Divider with "OR" text
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: (isDark ? AppTheme.dividerDark : AppTheme.dividerLight)
                      .withOpacity(0.5),
                  thickness: 1,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  'OR',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: (isDark ? AppTheme.dividerDark : AppTheme.dividerLight)
                      .withOpacity(0.5),
                  thickness: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Google Sign Up Button
          _buildSocialButton(
            context: context,
            onPressed: isLoading ? null : onGoogleSignUp,
            icon: 'g_logo',
            text: 'Sign up with Google',
            backgroundColor:
                isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
            textColor:
                isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
            borderColor: (isDark ? AppTheme.dividerDark : AppTheme.dividerLight)
                .withOpacity(0.3),
          ),

          // Apple Sign Up Button (iOS only)
          if (onAppleSignUp != null) ...[
            SizedBox(height: 2.h),
            _buildSocialButton(
              context: context,
              onPressed: isLoading ? null : onAppleSignUp!,
              icon: 'apple',
              text: 'Sign up with Apple',
              backgroundColor:
                  isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
              textColor:
                  isDark ? AppTheme.textPrimaryLight : AppTheme.textPrimaryDark,
              borderColor: Colors.transparent,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required VoidCallback? onPressed,
    required String icon,
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required Color borderColor,
  }) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          side: BorderSide(color: borderColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon(icon, textColor),
            SizedBox(width: 3.w),
            Text(
              text,
              style: theme.textTheme.labelLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(String iconType, Color color) {
    switch (iconType) {
      case 'g_logo':
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
          ),
          child: CustomIconWidget(
            iconName: 'g_translate',
            color: color,
            size: 20,
          ),
        );
      case 'apple':
        return CustomIconWidget(
          iconName: 'apple',
          color: color,
          size: 20,
        );
      default:
        return CustomIconWidget(
          iconName: 'login',
          color: color,
          size: 20,
        );
    }
  }
}
