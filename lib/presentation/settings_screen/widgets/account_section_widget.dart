import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AccountSectionWidget extends StatelessWidget {
  final VoidCallback onLogout;

  const AccountSectionWidget({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: AppTheme.glassmorphismDecoration(isLight: !isDark),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            leading: Container(
              width: 12.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'account_circle',
                  color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                  size: 24,
                ),
              ),
            ),
            title: Text(
              'Account',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Manage your account settings',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
            ),
          ),
          Divider(
            color: (isDark ? AppTheme.dividerDark : AppTheme.dividerLight)
                .withOpacity(0.3),
            height: 1,
          ),
          ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            leading: SizedBox(width: 12.w),
            title: Text(
              'Profile Information',
              style: theme.textTheme.bodyMedium,
            ),
            trailing: CustomIconWidget(
              iconName: 'keyboard_arrow_right',
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
              size: 20,
            ),
            onTap: () {
              // Navigate to profile screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Profile settings coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            leading: SizedBox(width: 12.w),
            title: Text(
              'Privacy & Security',
              style: theme.textTheme.bodyMedium,
            ),
            trailing: CustomIconWidget(
              iconName: 'keyboard_arrow_right',
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
              size: 20,
            ),
            onTap: () {
              // Navigate to privacy screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Privacy settings coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            leading: SizedBox(width: 12.w),
            title: Text(
              'Logout',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppTheme.errorDark : AppTheme.errorLight,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: CustomIconWidget(
              iconName: 'logout',
              color: isDark ? AppTheme.errorDark : AppTheme.errorLight,
              size: 20,
            ),
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.dialogDark : AppTheme.dialogLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Logout',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to logout? You will need to sign in again to access your account.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDark ? AppTheme.errorDark : AppTheme.errorLight,
              foregroundColor:
                  isDark ? AppTheme.onErrorDark : AppTheme.onErrorLight,
            ),
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}
