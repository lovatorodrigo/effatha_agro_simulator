import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LanguageSelectorWidget extends StatelessWidget {
  final String selectedLanguage;
  final Function(String) onLanguageChanged;

  const LanguageSelectorWidget({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
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
              iconName: 'language',
              color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
              size: 24,
            ),
          ),
        ),
        title: Text(
          'Language',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          _getLanguageDisplayName(selectedLanguage),
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
        onTap: () => _showLanguagePicker(context),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
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
                    'Select Language',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            ..._languages.map((language) {
              final isSelected = language['code'] == selectedLanguage;
              return ListTile(
                leading: Container(
                  width: 10.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                                ? AppTheme.primaryDark
                                : AppTheme.primaryLight)
                            .withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      language['flag'] as String,
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ),
                ),
                title: Text(
                  language['name'] as String,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? (isDark
                            ? AppTheme.primaryDark
                            : AppTheme.primaryLight)
                        : null,
                  ),
                ),
                subtitle: Text(
                  language['nativeName'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                  ),
                ),
                trailing: isSelected
                    ? CustomIconWidget(
                        iconName: 'check_circle',
                        color: isDark
                            ? AppTheme.primaryDark
                            : AppTheme.primaryLight,
                        size: 24,
                      )
                    : null,
                onTap: () {
                  onLanguageChanged(language['code'] as String);
                  Navigator.pop(context);
                },
              );
            }).toList(),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  String _getLanguageDisplayName(String languageCode) {
    final language = _languages.firstWhere(
      (l) => l['code'] == languageCode,
      orElse: () => _languages[0],
    );
    return language['name'] as String;
  }

  static const List<Map<String, String>> _languages = [
    {
      'code': 'pt_BR',
      'name': 'Portuguese (Brazil)',
      'nativeName': 'Português (Brasil)',
      'flag': '🇧🇷',
    },
    {
      'code': 'en',
      'name': 'English',
      'nativeName': 'English',
      'flag': '🇺🇸',
    },
    {
      'code': 'es',
      'name': 'Spanish',
      'nativeName': 'Español',
      'flag': '🇪🇸',
    },
  ];
}
