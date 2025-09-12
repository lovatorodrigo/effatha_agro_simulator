import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ExchangeRateWidget extends StatefulWidget {
  final bool isManualMode;
  final Map<String, double> exchangeRates;
  final Function(bool) onModeChanged;
  final Function(String, double) onRateChanged;

  const ExchangeRateWidget({
    super.key,
    required this.isManualMode,
    required this.exchangeRates,
    required this.onModeChanged,
    required this.onRateChanged,
  });

  @override
  State<ExchangeRateWidget> createState() => _ExchangeRateWidgetState();
}

class _ExchangeRateWidgetState extends State<ExchangeRateWidget> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeControllers() {
    for (final entry in widget.exchangeRates.entries) {
      _controllers[entry.key] = TextEditingController(
        text: entry.value.toStringAsFixed(4),
      );
    }
  }

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
                  iconName: 'currency_exchange',
                  color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                  size: 24,
                ),
              ),
            ),
            title: Text(
              'Exchange Rates',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              widget.isManualMode ? 'Manual mode' : 'Automatic mode',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
            ),
            trailing: Switch(
              value: widget.isManualMode,
              onChanged: widget.onModeChanged,
              activeColor:
                  isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
            ),
          ),
          if (widget.isManualMode) ...[
            Divider(
              color: (isDark ? AppTheme.dividerDark : AppTheme.dividerLight)
                  .withOpacity(0.3),
              height: 1,
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manual Exchange Rates',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  ..._buildExchangeRateFields(theme, isDark),
                  SizedBox(height: 1.h),
                  Text(
                    'Last updated: ${_getLastUpdatedTime()}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildExchangeRateFields(ThemeData theme, bool isDark) {
    final majorCurrencies = ['USD', 'EUR', 'GBP', 'JPY'];

    return majorCurrencies.map((currency) {
      final controller = _controllers[currency];
      if (controller == null) return SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.only(bottom: 2.h),
        child: Row(
          children: [
            Container(
              width: 20.w,
              child: Text(
                '1 $currency =',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,4}')),
                ],
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: (isDark
                              ? AppTheme.dividerDark
                              : AppTheme.dividerLight)
                          .withOpacity(0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color:
                          isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                      width: 2,
                    ),
                  ),
                  suffixText: 'BRL',
                  suffixStyle: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                  ),
                ),
                onChanged: (value) {
                  final rate = double.tryParse(value);
                  if (rate != null && rate > 0) {
                    widget.onRateChanged(currency, rate);
                  }
                },
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _getLastUpdatedTime() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
