import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CurrencySelectorWidget extends StatelessWidget {
  final String selectedCurrency;
  final Function(String) onCurrencyChanged;

  const CurrencySelectorWidget({
    super.key,
    required this.selectedCurrency,
    required this.onCurrencyChanged,
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
            child: Text(
              _getCurrencyFlag(selectedCurrency),
              style: TextStyle(fontSize: 18.sp),
            ),
          ),
        ),
        title: Text(
          'Currency',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${_getCurrencyName(selectedCurrency)} ($selectedCurrency)',
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
        onTap: () => _showCurrencyPicker(context),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 80.h,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
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
                    'Select Currency',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _currencies.length,
                itemBuilder: (context, index) {
                  final currency = _currencies[index];
                  final isSelected = currency['code'] == selectedCurrency;

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
                          currency['flag'] as String,
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                    ),
                    title: Text(
                      currency['name'] as String,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? (isDark
                                ? AppTheme.primaryDark
                                : AppTheme.primaryLight)
                            : null,
                      ),
                    ),
                    subtitle: Text(
                      currency['code'] as String,
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
                      onCurrencyChanged(currency['code'] as String);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrencyFlag(String currencyCode) {
    final currency = _currencies.firstWhere(
      (c) => c['code'] == currencyCode,
      orElse: () => _currencies[0],
    );
    return currency['flag'] as String;
  }

  String _getCurrencyName(String currencyCode) {
    final currency = _currencies.firstWhere(
      (c) => c['code'] == currencyCode,
      orElse: () => _currencies[0],
    );
    return currency['name'] as String;
  }

  static const List<Map<String, String>> _currencies = [
    {'code': 'BRL', 'name': 'Brazilian Real', 'flag': '🇧🇷'},
    {'code': 'USD', 'name': 'US Dollar', 'flag': '🇺🇸'},
    {'code': 'EUR', 'name': 'Euro', 'flag': '🇪🇺'},
    {'code': 'GBP', 'name': 'British Pound', 'flag': '🇬🇧'},
    {'code': 'JPY', 'name': 'Japanese Yen', 'flag': '🇯🇵'},
    {'code': 'CNY', 'name': 'Chinese Yuan', 'flag': '🇨🇳'},
    {'code': 'CAD', 'name': 'Canadian Dollar', 'flag': '🇨🇦'},
    {'code': 'AUD', 'name': 'Australian Dollar', 'flag': '🇦🇺'},
    {'code': 'CHF', 'name': 'Swiss Franc', 'flag': '🇨🇭'},
    {'code': 'MXN', 'name': 'Mexican Peso', 'flag': '🇲🇽'},
    {'code': 'ARS', 'name': 'Argentine Peso', 'flag': '🇦🇷'},
    {'code': 'CLP', 'name': 'Chilean Peso', 'flag': '🇨🇱'},
    {'code': 'COP', 'name': 'Colombian Peso', 'flag': '🇨🇴'},
    {'code': 'PEN', 'name': 'Peruvian Sol', 'flag': '🇵🇪'},
    {'code': 'ZAR', 'name': 'South African Rand', 'flag': '🇿🇦'},
    {'code': 'INR', 'name': 'Indian Rupee', 'flag': '🇮🇳'},
    {'code': 'TRY', 'name': 'Turkish Lira', 'flag': '🇹🇷'},
    {'code': 'KRW', 'name': 'South Korean Won', 'flag': '🇰🇷'},
    {'code': 'NZD', 'name': 'New Zealand Dollar', 'flag': '🇳🇿'},
    {'code': 'NOK', 'name': 'Norwegian Krone', 'flag': '🇳🇴'},
    {'code': 'SEK', 'name': 'Swedish Krona', 'flag': '🇸🇪'},
    {'code': 'DKK', 'name': 'Danish Krone', 'flag': '🇩🇰'},
    {'code': 'PLN', 'name': 'Polish Zloty', 'flag': '🇵🇱'},
  ];
}
