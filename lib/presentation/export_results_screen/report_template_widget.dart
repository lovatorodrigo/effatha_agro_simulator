import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportTemplateWidget extends StatelessWidget {
  final Map<String, dynamic> traditional;
  final Map<String, dynamic> effatha;
  final String cropKey;
  final String areaUnit;
  final String productivityUnit;
  final double kgPerSack;

  const ReportTemplateWidget({
    super.key,
    required this.traditional,
    required this.effatha,
    required this.cropKey,
    required this.areaUnit,
    required this.productivityUnit,
    this.kgPerSack = 60.0,
  });

  String _fmtMoney(double v) =>
      NumberFormat.currency(locale: 'pt_BR', symbol: r'$ ', decimalDigits: 2)
          .format(v);

  String _fmtPercent(double v, {int decimals = 1}) {
    final fixed = double.parse(v.toStringAsFixed(decimals));
    return '${NumberFormat.decimalPattern('pt_BR').format(fixed)}%';
  }

  String _prodKgToSc(double kg) {
    final sc = kgPerSack > 0 ? kg / kgPerSack : 0;
    return '${NumberFormat.decimalPattern('pt_BR').format(sc.round())} sc';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final tProfit = (traditional['profit'] as double?) ?? 0.0;
    final eProfit = (effatha['profit'] as double?) ?? 0.0;
    final tRevenue = (traditional['revenue'] as double?) ?? 0.0;
    final eRevenue = (effatha['revenue'] as double?) ?? 0.0;
    final tProdKg = (traditional['_productionKg'] as double?) ?? 0.0;
    final eProdKg = (effatha['_productionKg'] as double?) ?? 0.0;
    final tCosts = (traditional['_totalCosts'] as double?) ?? 0.0;
    final eCosts = (effatha['_totalCosts'] as double?) ?? 0.0;
    final tPerc = (traditional['_profitabilityRaw'] as double?) ?? 0.0;
    final ePerc = (effatha['_profitabilityRaw'] as double?) ?? 0.0;

    final diffMoney = eProfit - tProfit;
    final comparisonPct =
        (tPerc != 0) ? (((ePerc / tPerc) * 100.0) - 100.0) : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: DefaultTextStyle(
        style: theme.textTheme.bodyMedium!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resultados',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),

            // Tabela de duas colunas (igual ao Dashboard/PDF)
            _row2('Investimento Total (R\$)', _fmtMoney(tCosts), _fmtMoney(eCosts)),
            _row2('Produção Total', _prodKgToSc(tProdKg), _prodKgToSc(eProdKg)),
            _row2('Faturamento Total (R\$)', _fmtMoney(tRevenue), _fmtMoney(eRevenue)),
            _row2('Rentabilidade Total (R\$)', _fmtMoney(tProfit), _fmtMoney(eProfit)),
            _row2('Rentabilidade Total (%)',
                _fmtPercent(tPerc), _fmtPercent(ePerc)),

            const SizedBox(height: 12),

            // Destaque Rentabilidade
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2ecc71), Color(0xFF27ae60)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: DefaultTextStyle(
                style: theme.textTheme.bodyMedium!.copyWith(color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rentabilidade',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        )),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _tile('Diferença (R\$)', _fmtMoney(diffMoney)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _tile(
                              'Comparação (%)',
                              _fmtPercent(
                                comparisonPct,
                                decimals: 2,
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row2(String label, String left, String right) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: _kv('$label (Padrão Fazenda)', left),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _kv('$label (Effatha)', right),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k, style: const TextStyle(color: Colors.black54, fontSize: 12)),
        const SizedBox(height: 4),
        Text(v),
      ],
    );
  }

  Widget _tile(String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.28)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
