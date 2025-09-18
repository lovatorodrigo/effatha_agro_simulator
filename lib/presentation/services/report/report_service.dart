import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Mantemos a mesma estrutura usada no Dashboard:
/// - traditional / effatha: mapas com chaves:
///   'profit' (double), 'revenue' (double),
///   '_productionKg' (double), '_totalCosts' (double),
///   '_profitabilityRaw' (double),
///   além de versões formatadas que não usamos aqui.
/// - areaUnit, productivityUnit e kgPerSack replicam a tela.
class SimulationReportData {
  final Map<String, dynamic> traditional;
  final Map<String, dynamic> effatha;
  final String cropKey;
  final String areaUnit;          // 'hectares' | 'acres'
  final String productivityUnit;  // 'kg/ha' | 't/ha' | 'sc/ha' | 'sc/acre'
  final double kgPerSack;

  const SimulationReportData({
    required this.traditional,
    required this.effatha,
    required this.cropKey,
    required this.areaUnit,
    required this.productivityUnit,
    required this.kgPerSack,
  });
}

class ReportService {
  static String _fmtMoneyBR(double v) =>
      NumberFormat.currency(locale: 'pt_BR', symbol: r'$ ', decimalDigits: 2)
          .format(v);

  static String _fmtPercentBR(double v, {int decimals = 1}) {
    final fixed = double.parse(v.toStringAsFixed(decimals));
    return '${NumberFormat.decimalPattern('pt_BR').format(fixed)}%';
  }

  static String _fmtIntBR(num v) =>
      NumberFormat.decimalPattern('pt_BR').format(v);

  static String _prodKgToSc(double kg, double kgPerSack) {
    final sc = kgPerSack > 0 ? (kg / kgPerSack) : 0.0;
    return '${_fmtIntBR(sc.round())} sc';
  }

  /// Gera o PDF com o mesmo conteúdo do card branco do Dashboard.
  static Future<Uint8List> buildSimulationPdf(SimulationReportData data) async {
    final pdf = pw.Document();

    // Extrai os valores CRUS (iguais ao dashboard)
    final tProfit = (data.traditional['profit'] as double?) ?? 0.0;
    final eProfit = (data.effatha['profit'] as double?) ?? 0.0;

    final tRevenue = (data.traditional['revenue'] as double?) ?? 0.0;
    final eRevenue = (data.effatha['revenue'] as double?) ?? 0.0;

    final tProdKg = (data.traditional['_productionKg'] as double?) ?? 0.0;
    final eProdKg = (data.effatha['_productionKg'] as double?) ?? 0.0;

    final tCosts = (data.traditional['_totalCosts'] as double?) ?? 0.0;
    final eCosts = (data.effatha['_totalCosts'] as double?) ?? 0.0;

    final tPerc = (data.traditional['_profitabilityRaw'] as double?) ?? 0.0;
    final ePerc = (data.effatha['_profitabilityRaw'] as double?) ?? 0.0;

    // Seção de destaque (mesmo cálculo da tela)
    final diffMoney = eProfit - tProfit;
    final comparisonPct = (tPerc != 0)
        ? (((ePerc / tPerc) * 100.0) - 100.0)
        : 0.0;

    final now = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        build: (ctx) => [
          // Cabeçalho
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Effatha Agro Simulator',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      )),
                  pw.Text('Relatório de Simulação',
                      style: const pw.TextStyle(fontSize: 12)),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'Cultura: ${_cropName(data.cropKey)}   '
                    'Unid. área: ${data.areaUnit}   '
                    'Unid. produtividade: ${data.productivityUnit}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
              pw.Text(now, style: const pw.TextStyle(fontSize: 10)),
            ],
          ),
          pw.SizedBox(height: 14),

          // SEÇÃO: Resultados (igual ao card branco)
          pw.Text('Resultados',
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),

          // Tabela principal
          _twoColsTable(
            leftTitle: 'Padrão Fazenda',
            rightTitle: 'Effatha',
            rows: [
              [
                'Investimento Total (R\$)',
                _fmtMoneyBR(tCosts),
                _fmtMoneyBR(eCosts),
              ],
              [
                'Produção Total',
                _prodKgToSc(tProdKg, data.kgPerSack),
                _prodKgToSc(eProdKg, data.kgPerSack),
              ],
              [
                'Faturamento Total (R\$)',
                _fmtMoneyBR(tRevenue),
                _fmtMoneyBR(eRevenue),
              ],
              [
                'Rentabilidade Total (R\$)',
                _fmtMoneyBR(tProfit),
                _fmtMoneyBR(eProfit),
              ],
              [
                'Rentabilidade Total (%)',
                _fmtPercentBR(tPerc),
                _fmtPercentBR(ePerc),
              ],
            ],
          ),

          pw.SizedBox(height: 18),

          // SEÇÃO DESTAQUE: Rentabilidade
          _highlightBox(
            title: 'Rentabilidade',
            leftLabel: 'Diferença (R\$)',
            leftValue: _fmtMoneyBR(diffMoney),
            rightLabel: 'Comparação (%)',
            rightValue: _fmtPercentBR(comparisonPct, decimals: 2),
          ),

          pw.SizedBox(height: 12),

          // Rodapé de observações
          pw.Text(
            'Observações',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Bullet(
            text:
                'As unidades exibidas refletem as preferências de exibição do usuário no momento da exportação (área: ${data.areaUnit}, produtividade: ${data.productivityUnit}).',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Bullet(
            text:
                'Cálculos internos usam padrões SI (ha, kg/ha, \$\/kg, \$\/ha). Peso da saca: ${_fmtIntBR(data.kgPerSack)} kg.',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _twoColsTable({
    required String leftTitle,
    required String rightTitle,
    required List<List<String>> rows, // [label, left, right]
  }) {
    final headerStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.black,
      fontSize: 11,
    );
    final cellStyle = const pw.TextStyle(fontSize: 11);

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2.8),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFEFF4F1)),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text('Métrica', style: headerStyle),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(leftTitle, style: headerStyle),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(rightTitle, style: headerStyle),
            ),
          ],
        ),
        ...rows.map(
          (r) => pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(r[0], style: cellStyle),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(r[1], style: cellStyle),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(r[2], style: cellStyle),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _highlightBox({
    required String title,
    required String leftLabel,
    required String leftValue,
    required String rightLabel,
    required String rightValue,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
          colors: [
            PdfColor.fromInt(0xFF2ECC71),
            PdfColor.fromInt(0xFF27AE60),
          ],
        ),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      padding: const pw.EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Título continua branco (melhor contraste sobre o gradiente)
          pw.Text(
            title,
            style: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 12,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Row(
            children: [
              pw.Expanded(
                child: _miniTile(leftLabel, leftValue),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: _miniTile(rightLabel, rightValue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // >>> AQUI fizemos a troca de cores internas para VERDE <<<
  static pw.Widget _miniTile(String label, String value) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColor(1, 1, 1, 0.16), // fundo translúcido (sem withOpacity)
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.green, width: 0.3), // borda verde
      ),
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              color: PdfColors.green, // label em verde
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            value,
            style: pw.TextStyle(
              color: PdfColors.green, // valor em verde
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static String _cropName(String key) {
    switch (key) {
      case 'soy':
        return 'Soja';
      case 'corn':
        return 'Milho';
      case 'cotton':
        return 'Algodão';
      case 'sugarcane':
        return 'Cana-de-açúcar';
      case 'wheat':
        return 'Trigo';
      case 'coffee':
        return 'Café';
      case 'orange':
        return 'Laranja';
      default:
        return key;
    }
  }
}
