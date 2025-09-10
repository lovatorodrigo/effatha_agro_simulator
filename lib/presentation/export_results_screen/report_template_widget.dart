
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';

class ReportTemplateWidget extends StatelessWidget {
  final Map<String, dynamic> traditional;
  final Map<String, dynamic> effatha;
  final String cropKey;
  final String areaUnit;
  final String productivityUnit;

  const ReportTemplateWidget({
    super.key,
    required this.traditional,
    required this.effatha,
    required this.cropKey,
    required this.areaUnit,
    required this.productivityUnit,
  });

  String _cropAsset(String key) {
    switch (key) {
      case 'soy': return 'assets/images/bg_sim_soy.jpg';
      case 'corn': return 'assets/images/bg_sim_corn.jpg';
      case 'cotton': return 'assets/images/bg_sim_cotton.jpg';
      case 'sugarcane': return 'assets/images/bg_sim_sugarcane.jpg';
      case 'wheat': return 'assets/images/bg_sim_wheat.jpg';
      case 'coffee': return 'assets/images/bg_sim_coffee.jpg';
      case 'orange': return 'assets/images/bg_sim_orange.jpg';
      default: return 'assets/images/bg_sim_soy.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AspectRatio(
      aspectRatio: 210 / 297, // A4 portrait
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(_cropAsset(cropKey), fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.15),
                  Colors.transparent,
                  Colors.black.withOpacity(0.15),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset('assets/images/effatha_logo.png', height: 40),
                    SizedBox(width: 12),
                    Text(
                      'Effatha Agro Simulator — Report',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _card(theme, isDark, 'Profitability Analysis', [
                  _row('Investment (Total)', traditional['investmentTotal'] ?? '-', effatha['investmentTotal'] ?? '-'),
                  _row('Production (Total)', traditional['productionTotal'] ?? '-', effatha['productionTotal'] ?? '-'),
                  _row('Profitability', traditional['profitabilityPercent'] ?? '0%', effatha['profitabilityPercent'] ?? '0%'),
                  _row('ROI', traditional['roi'] ?? '0%', effatha['roi'] ?? '0%'),
                ]),
                SizedBox(height: 12),
                _card(theme, isDark, 'Additional Profit with Effatha', [
                  _row('Additional Profit', '', effatha['additionalProfit'] ?? r'$ 0,00'),
                  _row('vs Traditional', '', effatha['additionalProfitPercent'] ?? '0%'),
                ]),
                const Spacer(),
                Text(
                  'Units: area=$areaUnit • productivity=$productivityUnit',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(ThemeData theme, bool isDark, String title, List<Widget> rows) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          SizedBox(height: 8),
          ...rows,
        ],
      ),
    );
  }

  Widget _row(String label, String trad, String eff) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label)),
          Expanded(flex: 2, child: Text(trad, textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text(eff, textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}
