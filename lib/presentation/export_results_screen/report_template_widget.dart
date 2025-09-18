import 'package:flutter/material.dart';
import 'package:effatha_agro_simulator/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);

    return AspectRatio(
      aspectRatio: 210 / 297, // A4 em pé
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
                // Cabeçalho
                Row(
                  children: [
                    Image.asset('assets/images/logo_effatha.png', height: 40),
                    const SizedBox(width: 12),
                    Text(
                      l10n?.exportReport ?? 'Effatha Agro Simulator — Report',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Card: Profitability Analysis
                _card(
                  theme,
                  title:
                      l10n?.profitabilityAnalysis ?? 'Profitability Analysis',
                  rows: [
                    _row(
                      label: l10n?.investmentTotal ?? 'Investment (Total)',
                      trad: (traditional['investmentTotal'] ?? '-').toString(),
                      eff: (effatha['investmentTotal'] ?? '-').toString(),
                      theme: theme,
                    ),
                    _row(
                      label: l10n?.productionTotal ?? 'Production (Total)',
                      trad:
                          (traditional['productionTotal'] ?? '-').toString(),
                      eff: (effatha['productionTotal'] ?? '-').toString(),
                      theme: theme,
                    ),
                    _row(
                      label: l10n?.profitability ?? 'Profitability',
                      trad: (traditional['profitabilityPercent'] ?? '0%')
                          .toString(),
                      eff: (effatha['profitabilityPercent'] ?? '0%').toString(),
                      theme: theme,
                    ),
                    _row(
                      label: l10n?.roi ?? 'ROI',
                      trad: (traditional['roi'] ?? '0%').toString(),
                      eff: (effatha['roi'] ?? '0%').toString(),
                      theme: theme,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Card: Additional Profit
                _card(
                  theme,
                  title: l10n?.additionalProfitWithEffatha ??
                      'Additional Profit with Effatha',
                  rows: [
                    _row(
                      label: l10n?.additionalProfit ?? 'Additional Profit',
                      trad: '',
                      eff: (effatha['additionalProfit'] ?? r'$ 0,00')
                          .toString(),
                      theme: theme,
                    ),
                    _row(
                      label: l10n?.vsTraditional ?? 'vs Traditional',
                      trad: '',
                      eff: (effatha['additionalProfitPercent'] ?? '0%')
                          .toString(),
                      theme: theme,
                    ),
                  ],
                ),

                const Spacer(),

                // Rodapé: unidades
                Text(
                  (l10n?.unitsLabel ?? 'Units') +
                      ': area=$areaUnit • productivity=$productivityUnit',
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
    required String label,
    required String trad,
    required String eff,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              trad,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              eff,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
