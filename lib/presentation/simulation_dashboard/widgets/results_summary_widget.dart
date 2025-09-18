import 'package:effatha_agro_simulator/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ResultsSummaryWidget extends StatelessWidget {
  final Map<String, dynamic> traditionalResults;
  final Map<String, dynamic> effathaResults;

  const ResultsSummaryWidget({
    super.key,
    required this.traditionalResults,
    required this.effathaResults,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    double tradProfit = (traditionalResults['profit'] ?? 0).toDouble();
    double tradRevenue = (traditionalResults['revenue'] ?? 0).toDouble();
    double effProfit = (effathaResults['profit'] ?? 0).toDouble();
    double effRevenue = (effathaResults['revenue'] ?? 0).toDouble();

    String tradMargin =
        tradRevenue > 0 ? '${((tradProfit / tradRevenue) * 100).toStringAsFixed(1)}%' : '0%';
    String effMargin =
        effRevenue > 0 ? '${((effProfit / effRevenue) * 100).toStringAsFixed(1)}%' : '0%';
    
    double parsePercent(String s) {
      final cleaned = s.replaceAll('%', '').trim();
      return double.tryParse(cleaned) ?? 0.0;
    }
    final tradROI = parsePercent(traditionalResults['roi'] ?? '0%');
    final effROI = parsePercent(effathaResults['roi'] ?? '0%');
    final roiGain = effROI - tradROI;
    final roiGainStr = '${roiGain.toStringAsFixed(1)}%';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profitability Analysis',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppTheme.textPrimaryLight,
          ),
        ),
        SizedBox(height: 1.h),

        Container(
          padding: EdgeInsets.symmetric(vertical: 0.8.h, horizontal: 2.w),
          decoration: BoxDecoration(
            color: (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight)
                .withOpacity(0.6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Metric',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
              ),
              Expanded(
                flex: 2,
                child: Text('Traditional',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
              ),
              Expanded(
                flex: 2,
                child: Text('Effatha',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
              ),
            ],
          ),
        ),
        SizedBox(height: 1.h),

        _buildSummaryRow(
          context,
          'Investment (Total)',
          traditionalResults['investmentTotal'] ?? '-',
          effathaResults['investmentTotal'] ?? '-',
          isDark,
        ),
        SizedBox(height: 1.h),
        _buildSummaryRow(
          context,
          'Production (Total)',
          traditionalResults['productionTotal'] ?? '-',
          effathaResults['productionTotal'] ?? '-',
          isDark,
        ),
        SizedBox(height: 1.h),
        _buildSummaryRow(
          context,
          'Profitability',
          traditionalResults['profitabilityPercent'] ?? '0%',
          effathaResults['profitabilityPercent'] ?? '0%',
          isDark,
        ),
        SizedBox(height: 1.h),
        _buildSummaryRow(
          context,
          'Margin',
          tradMargin,
          effMargin,
          isDark,
        ),
        SizedBox(height: 1.h),
        _buildSummaryRow(
          context,
          'ROI',
          traditionalResults['roi'] ?? '0%',
          effathaResults['roi'] ?? '0%',
          isDark,
        ),
        SizedBox(height: 1.h),
        _buildSummaryRow(
          context,
          'ROI Gain (Effatha - Traditional)',
          '',
          roiGainStr,
          isDark,
        ),
        SizedBox(height: 3.h),

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: (isDark ? AppTheme.successDark : AppTheme.successLight)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (isDark ? AppTheme.successDark : AppTheme.successLight)
                  .withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Additional Profit with Effatha',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color:
                      isDark ? AppTheme.successDark : AppTheme.successLight,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                effathaResults['additionalProfit'] ?? '\$0',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppTheme.successDark
                      : AppTheme.successLight,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'vs traditional: ${effathaResults['additionalProfitPercent'] ?? '0%'}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String traditionalValue,
    String effathaValue,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            traditionalValue,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            effathaValue,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
