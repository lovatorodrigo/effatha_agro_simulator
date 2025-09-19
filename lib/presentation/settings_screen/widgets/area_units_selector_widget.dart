import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AreaUnitsSelectorWidget extends StatelessWidget {
  final String selectedUnit;
  final Function(String) onUnitChanged;

  const AreaUnitsSelectorWidget({
    super.key,
    required this.selectedUnit,
    required this.onUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: AppTheme.glassmorphismDecoration(isLight: !isDark),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
              iconName: 'crop_free',
              color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
              size: 24,
            ),
          ),
        ),
        title: Text(
          'Area Units',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          _getUnitDisplayName(selectedUnit),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark
                ? AppTheme.textSecondaryDark
                : AppTheme.textSecondaryLight,
          ),
        ),
        trailing: CustomIconWidget(
          iconName: 'keyboard_arrow_right',
          color:
              isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
          size: 24,
        ),
        onTap: () => _showUnitPicker(context),
      ),
    );
  }

  void _showUnitPicker(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  Container(
                    width: 10.w,
                    height: 0.5.h,
                    decoration: BoxDecoration(
                      color:
                          isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Select Area Unit',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            ..._areaUnits.map((unit) {
              final isSelected = unit['code'] == selectedUnit;
              return RadioListTile<String>(
                value: unit['code'] as String,
                groupValue: selectedUnit,
                onChanged: (value) {
                  if (value != null) {
                    onUnitChanged(value);
                    Navigator.pop(context);
                  }
                },
                title: Text(
                  unit['name'] as String,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                subtitle: Text(
                  unit['description'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                  ),
                ),
                activeColor:
                    isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
              );
            }).toList(),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  String _getUnitDisplayName(String unitCode) {
    final unit = _areaUnits.firstWhere(
      (u) => u['code'] == unitCode,
      orElse: () => _areaUnits[0],
    );
    return unit['name'] as String;
  }

  static const List<Map<String, String>> _areaUnits = [
    {
      'code': 'hectares',
      'name': 'Hectares',
      'description': '1 hectare = 10,000 m²',
    },
    {
      'code': 'acres',
      'name': 'Acres',
      'description': '1 acre = 4,047 m²',
    },
    {
      'code': 'square_meters',
      'name': 'Square Meters',
      'description': 'Base metric unit',
    },
    {
      'code': 'custom',
      'name': 'Custom Unit',
      'description': 'Define your own area unit',
    },
  ];
}
