import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SocialLoginWidget extends StatelessWidget {
  final VoidCallback? onGoogleSignIn;
  final VoidCallback? onAppleSignIn;
  final bool isLoading;

  const SocialLoginWidget({
    super.key,
    this.onGoogleSignIn,
    this.onAppleSignIn,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 85.w,
      constraints: BoxConstraints(maxWidth: 400),
      child: Column(
        children: [
          // Divider with "OR" text
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: (isDark ? AppTheme.dividerDark : AppTheme.dividerLight)
                      .withOpacity(0.3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: (isDark ? AppTheme.dividerDark : AppTheme.dividerLight)
                      .withOpacity(0.3),
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Social Login Buttons
          Column(
            children: [
              // Google Sign-In Button
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : onGoogleSignIn,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isDark
                        ? AppTheme.surfaceDark.withOpacity(0.8)
                        : AppTheme.surfaceLight.withOpacity(0.9),
                    foregroundColor: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                    side: BorderSide(
                      color: (isDark
                              ? AppTheme.dividerDark
                              : AppTheme.dividerLight)
                          .withOpacity(0.3),
                      width: 1.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  icon: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: CustomImageWidget(
                      imageUrl:
                          "https://developers.google.com/identity/images/g-logo.png",
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                  ),
                  label: Text(
                    'Continue with Google',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),

              // Apple Sign-In Button (iOS only)
              if (!kIsWeb &&
                  Theme.of(context).platform == TargetPlatform.iOS) ...[
                SizedBox(height: 1.5.h),
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : onAppleSignIn,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isDark
                          ? AppTheme.surfaceDark.withOpacity(0.8)
                          : AppTheme.surfaceLight.withOpacity(0.9),
                      foregroundColor: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                      side: BorderSide(
                        color: (isDark
                                ? AppTheme.dividerDark
                                : AppTheme.dividerLight)
                            .withOpacity(0.3),
                        width: 1.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    icon: CustomIconWidget(
                      iconName: 'apple',
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                      size: 24,
                    ),
                    label: Text(
                      'Continue with Apple',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),

          SizedBox(height: 4.h),

          // Create Account Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'New to Effatha? ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
              ),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        Navigator.pushNamed(context, '/registration-screen');
                      },
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  minimumSize: Size(0, 5.h),
                ),
                child: Text(
                  'Create Account',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color:
                        isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor:
                        isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
