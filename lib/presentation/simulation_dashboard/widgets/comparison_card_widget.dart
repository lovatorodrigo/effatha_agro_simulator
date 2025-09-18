import 'package:effatha_agro_simulator/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ComparisonCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final bool isEffatha;
  final Color? accentColor;

  /// Optional custom asset for the Effatha logo. Defaults to assets/images/effatha_logo.png
  final String effathaLogoAsset;

  const ComparisonCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    this.isEffatha = false,
    this.accentColor,
    this.effathaLogoAsset = 'assets/images/effatha_logo.png',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: AppTheme.cardDecoration(isLight: !isDark).copyWith(
        border: Border.all(
          color: (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
              .withOpacity(0.2),
          width: isEffatha ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppTheme.shadowDark : AppTheme.shadowLight)
                .withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isEffatha) ...[
                SizedBox(width: 2.w),
                Container(
                  constraints: const BoxConstraints(minWidth: 64, minHeight: 24),
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                  decoration: BoxDecoration(
                    color: (accentColor ??
                            (isDark
                                ? AppTheme.primaryDark
                                : AppTheme.primaryLight))
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Image.asset(
                      effathaLogoAsset,
                      height: 18,
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, obj, stack) => Text(
                        'Effatha',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: accentColor ??
                              (isDark
                                  ? AppTheme.primaryDark
                                  : AppTheme.primaryLight),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: isEffatha
                  ? (accentColor ??
                      (isDark ? AppTheme.primaryDark : AppTheme.primaryLight))
                  : (isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimaryLight),
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
