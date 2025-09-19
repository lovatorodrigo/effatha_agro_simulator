import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CropSelectorWidget extends StatelessWidget {
  final String selectedCrop;
  final ValueChanged<String> onCropChanged;

  const CropSelectorWidget({
    super.key,
    required this.selectedCrop,
    required this.onCropChanged,
  });

  static const Map<String, String> _displayNames = {
    'soy': 'Soy',
    'corn': 'Corn',
    'cotton': 'Cotton',
    'sugarcane': 'Sugarcane',
    'wheat': 'Wheat',
    'coffee': 'Coffee',
    'orange': 'Orange',
  };

  static const List<String> _crops = [
    'soy', 'corn', 'cotton', 'sugarcane', 'wheat', 'coffee', 'orange'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: AppTheme.cardDecoration(isLight: !isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Crop',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppTheme.textPrimaryDark
                  : AppTheme.textPrimaryLight,
            ),
          ),
          SizedBox(height: 1.h),
          DropdownButtonFormField<String>(
            value: _crops.contains(selectedCrop) ? selectedCrop : 'soy',
            items: _crops.map((c) {
              return DropdownMenuItem<String>(
                value: c,
                child: Text(_displayNames[c] ?? c),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) onCropChanged(val);
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            icon: CustomIconWidget(
              iconName: 'keyboard_arrow_down',
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
