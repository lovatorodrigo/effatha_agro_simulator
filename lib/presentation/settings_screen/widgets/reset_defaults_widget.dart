import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ResetDefaultsWidget extends StatelessWidget {
  final VoidCallback onResetDefaults;

  const ResetDefaultsWidget({
    super.key,
    required this.onResetDefaults,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: OutlinedButton.icon(
        onPressed: () => _showResetDialog(context),
        icon: CustomIconWidget(
          iconName: 'restore',
          color: isDark ? AppTheme.warningDark : AppTheme.warningLight,
          size: 20,
        ),
        label: Text(
          'Reset to Defaults',
          style: theme.textTheme.labelLarge?.copyWith(
            color: isDark ? AppTheme.warningDark : AppTheme.warningLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDark ? AppTheme.warningDark : AppTheme.warningLight,
            width: 1.5,
          ),
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.dialogDark : AppTheme.dialogLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'warning',
              color: isDark ? AppTheme.warningDark : AppTheme.warningLight,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Reset Settings',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will reset all settings to their default values:',
              style: theme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            ..._getDefaultSettings()
                .map((setting) => Padding(
                      padding: EdgeInsets.only(bottom: 1.h),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'fiber_manual_record',
                            color: isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight,
                            size: 8,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              setting,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppTheme.textSecondaryDark
                                    : AppTheme.textSecondaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
            SizedBox(height: 2.h),
            Text(
              'This action cannot be undone.',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: isDark ? AppTheme.warningDark : AppTheme.warningLight,
              ),
            ),
          ],
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
              onResetDefaults();
              _showResetConfirmation(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDark ? AppTheme.warningDark : AppTheme.warningLight,
              foregroundColor:
                  isDark ? AppTheme.onPrimaryDark : AppTheme.onPrimaryLight,
            ),
            child: Text('Reset All'),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.onPrimaryLight,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text('Settings reset to defaults successfully'),
          ],
        ),
        backgroundColor: AppTheme.successLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  List<String> _getDefaultSettings() {
    return [
      'Currency: Brazilian Real (BRL)',
      'Area Units: Hectares',
      'Language: Portuguese (Brazil)',
      'Kg per Sack Weight: 60.0 kg',
      'Exchange Rates: Automatic mode',
    ];
  }
}
