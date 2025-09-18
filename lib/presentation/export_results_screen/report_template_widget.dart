import 'package:flutter/material.dart';

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
      case 'soy':
        return 'assets/images/bg_sim_soy.jpg';
      case 'corn':
        return 'assets/images/bg_sim_corn.jpg';
      case 'cotton':
        return 'assets/images/bg_sim_cotton.jpg';
      case 'sugarcane':
        return 'assets/images/bg_sim_sugarcane.jpg';
      case 'wheat':
        return 'assets/images/bg_sim_wheat.jpg';
      case 'coffee':
        return 'assets/images/bg_sim_coffee.jpg';
      case 'orange':
        return 'assets/images/bg_sim_orange.jpg';
      default:
        return 'assets/images/bg_sim_soy.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset('assets/images/logo_effatha.png', height: 40),
                    const SizedBox(width: 12),
                    Text(
                      'Effatha Agro Simulator — Report',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _card(
                  theme,
                  title: 'Profitability Analysis',
                  rows: [
                    _row(
                      theme: theme,
                      label: 'Investment (Total)',
                      trad: (traditional['investmentTotal'] ?? '-').toString(),
                      eff: (effatha['investmentTotal'] ?? '-').toString(),
                    ),
                    _row(
                      theme: theme,
                      label: 'Production (Total)',
                      trad: (traditional['productionTotal'] ?? '-').toString(),
                      eff: (effatha['productionTotal'] ?? '-').toString(),
                    ),
                    _row(
                      theme: theme,
                      label: 'Profitability',
                      trad: (traditional['profitabilityPercent'] ?? '0%').toString(),
                      eff: (effatha['profitabilityPercent'] ?? '0%').toString(),
                    ),
                    _row(
                      theme: theme,
                      label: 'ROI',
                      trad: (traditional['roi'] ?? '0%').toString(),
                      eff: (effatha['roi'] ?? '0%').toString(),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                _card(
                  theme,
                  title: 'Additional Profit with Effatha',
                  rows: [
                    _row(
                      theme: theme,
                      label: 'Additional Profit',
                      trad: '',
                      eff: (effatha['additionalProfit'] ?? r'$ 0,00').toString(),
                    ),
                    _row(
                      theme: theme,
                      label: 'vs Traditional',
                      trad: '',
                      eff: (effatha['additionalProfitPercent'] ?? '0%').toString(),
                    ),
                  ],
                ),

                const Spacer(),
                Text(
                  'Units: area=$areaUnit • productivity=$productivityUnit',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(
    ThemeData theme, {
    required String title,
    required List<Widget> rows,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...rows,
        ],
      ),
    );
  }

  Widget _row({
    required ThemeData theme,
    required String label,
    required String trad,
    required String eff,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              trad,
              textAlign: TextAlign.center,
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              eff,
              textAlign: TextAlign.center,
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
