import 'package:flutter/material.dart';

class ResultsComparisonRows extends StatelessWidget {
  final Map<String, dynamic> tradicional; // _traditionalResults
  final Map<String, dynamic> effatha;     // _effathaResults
  final double kgPerSack;
  final String Function(double v) fmtMoney;   // $ pt_BR
  final String Function(double v) fmtPercent; // % pt_BR

  const ResultsComparisonRows({
    super.key,
    required this.tradicional,
    required this.effatha,
    required this.kgPerSack,
    required this.fmtMoney,
    required this.fmtPercent,
  });

  String _fmtSc(double kg) {
    if (kgPerSack <= 0) return '0 sc';
    final sc = kg / kgPerSack;
    return '${sc.toStringAsFixed(0)} sc';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // lê valores crus com fallback
    final tInvest   = (tradicional['investmentTotal'] ?? 0).toDouble();
    final eInvest   = (effatha['investmentTotal'] ?? 0).toDouble();

    final tProdKg   = (tradicional['productionKg'] ?? 0).toDouble();
    final eProdKg   = (effatha['productionKg'] ?? 0).toDouble();

    final tProfit   = (tradicional['profit'] ?? 0).toDouble();
    final eProfit   = (effatha['profit'] ?? 0).toDouble();

    final tRentPct  = (tradicional['profitabilityPercent'] ?? 0).toDouble();
    final eRentPct  = (effatha['profitabilityPercent'] ?? 0).toDouble();

    Widget header() {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            const Expanded(flex: 3, child: SizedBox()),
            Expanded(
              flex: 2,
              child: Text(
                'Padrão',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(color: Colors.black54),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Effatha',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(color: Colors.black54),
              ),
            ),
          ],
        ),
      );
    }

    Widget row(String label, String tValue, String eValue) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                tValue,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                eValue,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // título dentro do seu card branco
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Padrão Fazenda × Effatha',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        header(),
        const Divider(height: 1),
        row('Investimento Total', fmtMoney(tInvest), fmtMoney(eInvest)),
        const Divider(height: 1),
        row('Produção Total', _fmtSc(tProdKg), _fmtSc(eProdKg)),
        const Divider(height: 1),
        row('Rentabilidade Total (R\$)', fmtMoney(tProfit), fmtMoney(eProfit)),
        const Divider(height: 1),
        row('Rentabilidade Total (%)', fmtPercent(tRentPct), fmtPercent(eRentPct)),
      ],
    );
  }
}
