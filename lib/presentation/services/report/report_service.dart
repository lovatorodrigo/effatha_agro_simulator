import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class SimulationReportData {
  final Map<String, dynamic> traditional;
  final Map<String, dynamic> effatha;
  final String cropKey;
  final String areaUnit;
  final String productivityUnit;
  final double kgPerSack;
  final String locale;

  SimulationReportData({
    required this.traditional,
    required this.effatha,
    required this.cropKey,
    required this.areaUnit,
    required this.productivityUnit,
    required this.kgPerSack,
    this.locale = 'pt_BR',
  });
}

class ReportService {
  static String fmtMoney(num v) =>
      NumberFormat.currency(locale: 'pt_BR', symbol: r'$ ', decimalDigits: 2).format(v);

  static String fmtPercent(num v, {int decimals = 1}) {
    final d = double.tryParse(v.toString()) ?? 0.0;
    final r = double.parse(d.toStringAsFixed(decimals));
    return '${NumberFormat.decimalPattern('pt_BR').format(r)}%';
  }

  static Future<Uint8List> buildSimulationPdf(SimulationReportData data) async {
    final pdf = pw.Document();

    final bgPath = _cropAsset(data.cropKey);
    final logo = await _tryLoad('assets/images/effatha_logo.png');
    final bg = await _tryLoad(bgPath);

    final theme = pw.ThemeData.withFont(
      base: pw.Font.helvetica(),
      bold: pw.Font.helveticaBold(),
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          theme: theme,
          margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          buildBackground: (ctx) {
            if (bg == null) return pw.Container();
            return pw.FullPage(
              ignoreMargins: true,
              child: pw.Opacity(
                opacity: 0.15,
                child: pw.Image(pw.MemoryImage(bg), fit: pw.BoxFit.cover),
              ),
            );
          },
        ),
        header: (ctx) => _buildHeader(logo, data),
        footer: (ctx) => _buildFooter(ctx.pageNumber, ctx.pagesCount),
        build: (ctx) => [
          _buildOverview(data),
          pw.SizedBox(height: 12),
          _buildComparisonTable(data),
          pw.SizedBox(height: 12),
          _buildRoiAndMargin(data),
          pw.SizedBox(height: 16),
          _buildNotes(data),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(Uint8List? logo, SimulationReportData data) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (logo != null)
            pw.Container(
              width: 64,
              height: 64,
              child: pw.Image(pw.MemoryImage(logo), fit: pw.BoxFit.contain),
            ),
          if (logo != null) pw.SizedBox(width: 12),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Effatha Agro Simulator', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text('Simulation Report', style: const pw.TextStyle(fontSize: 12)),
              pw.Text('Crop: ${_cropName(data.cropKey)} • Area unit: ${data.areaUnit} • Productivity unit: ${data.productivityUnit}', style: const pw.TextStyle(fontSize: 10)),
            ],
          ),
          pw.Spacer(),
          pw.Text(
            DateFormat('dd/MM/yyyy HH:mm', data.locale).format(DateTime.now()),
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(int page, int pages) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Text('Page $page of $pages', style: const pw.TextStyle(fontSize: 10)),
    );
  }

  static pw.Widget _title(String text) => pw.Text(
        text,
        style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
      );

  static pw.Widget _buildOverview(SimulationReportData data) {
    final tradRev = (data.traditional['revenue'] ?? 0) as num;
    final effRev = (data.effatha['revenue'] ?? 0) as num;
    final tradProfit = (data.traditional['profit'] ?? 0) as num;
    final effProfit = (data.effatha['profit'] ?? 0) as num;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _title('Overview'),
        pw.SizedBox(height: 6),
        pw.Row(
          children: [
            _kv('Traditional Revenue', fmtMoney(tradRev)),
            pw.SizedBox(width: 18),
            _kv('Effatha Revenue', fmtMoney(effRev)),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            _kv('Traditional Profit', fmtMoney(tradProfit)),
            pw.SizedBox(width: 18),
            _kv('Effatha Profit', fmtMoney(effProfit)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _kv(String k, String v) => pw.Container(
        padding: const pw.EdgeInsets.only(right: 8, bottom: 2),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.baseline,
          textBaseline: pw.TextBaseline.alphabetic,
          children: [
            pw.Text('$k: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
            pw.Text(v, style: const pw.TextStyle(fontSize: 11)),
          ],
        ),
      );

  static pw.Widget _buildComparisonTable(SimulationReportData data) {
    String tradInv = data.traditional['investmentTotal']?.toString() ?? '-';
    String effInv = data.effatha['investmentTotal']?.toString() ?? '-';

    String tradProd = data.traditional['productionTotal']?.toString() ?? '-';
    String effProd = data.effatha['productionTotal']?.toString() ?? '-';

    String tradProfPct = data.traditional['profitabilityPercent']?.toString() ?? '0%';
    String effProfPct = data.effatha['profitabilityPercent']?.toString() ?? '0%';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _title('Profitability Analysis'),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.6),
          columnWidths: const {
            0: pw.FlexColumnWidth(2),
            1: pw.FlexColumnWidth(2),
            2: pw.FlexColumnWidth(2),
          },
          children: [
            _rowHeader(['Metric', 'Traditional', 'Effatha']),
            _row(['Investment (Total)', tradInv, effInv]),
            _row(['Production (Total)', tradProd, effProd]),
            _row(['Profitability', tradProfPct, effProfPct]),
          ],
        ),
      ],
    );
  }

  static pw.TableRow _rowHeader(List<String> cells) => pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFEFF3F6)),
        children: cells
            .map((c) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: pw.Text(c, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                ))
            .toList(),
      );

  static pw.TableRow _row(List<String> cells) => pw.TableRow(
        children: cells
            .map((c) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: pw.Text(c, style: const pw.TextStyle(fontSize: 11)),
                ))
            .toList(),
      );

  static pw.Widget _buildRoiAndMargin(SimulationReportData data) {
    final tradProfit = (data.traditional['profit'] ?? 0) as num;
    final tradRevenue = (data.traditional['revenue'] ?? 0) as num;
    final effProfit = (data.effatha['profit'] ?? 0) as num;
    final effRevenue = (data.effatha['revenue'] ?? 0) as num;

    final tradMargin = tradRevenue > 0 ? (tradProfit / tradRevenue) * 100 : 0.0;
    final effMargin = effRevenue > 0 ? (effProfit / effRevenue) * 100 : 0.0;

    double parsePct(dynamic s) {
      if (s == null) return 0;
      final t = s.toString().replaceAll('%', '').replaceAll(',', '.').trim();
      return double.tryParse(t) ?? 0.0;
    }

    final tradROI = parsePct(data.traditional['roi']);
    final effROI = parsePct(data.effatha['roi']);
    final roiGain = effROI - tradROI;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _title('ROI & Margin'),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.6),
          columnWidths: const {
            0: pw.FlexColumnWidth(2),
            1: pw.FlexColumnWidth(2),
            2: pw.FlexColumnWidth(2),
          },
          children: [
            _rowHeader(['Metric', 'Traditional', 'Effatha']),
            _row(['Margin', fmtPercent(tradMargin), fmtPercent(effMargin)]),
            _row(['ROI', data.traditional['roi']?.toString() ?? '0%', data.effatha['roi']?.toString() ?? '0%']),
            _row(['ROI Gain (Effatha - Trad.)', '', fmtPercent(roiGain)]),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildNotes(SimulationReportData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _title('Notes'),
        pw.SizedBox(height: 6),
        pw.Bullet(text: 'Units shown respect the user display preferences at the time of export (area: ${data.areaUnit}, productivity: ${data.productivityUnit}).'),
        pw.Bullet(text: 'Internal calculations use SI standards (ha, kg/ha, $/kg, $/ha). Sack weight: ${data.kgPerSack.toStringAsFixed(0)} kg.'),
      ],
    );
  }

  static String _cropName(String key) {
    switch (key) {
      case 'soy': return 'Soy';
      case 'corn': return 'Corn';
      case 'cotton': return 'Cotton';
      case 'sugarcane': return 'Sugarcane';
      case 'wheat': return 'Wheat';
      case 'coffee': return 'Coffee';
      case 'orange': return 'Orange';
      default: return key;
    }
  }

  static String _cropAsset(String key) {
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

  static Future<Uint8List?> _tryLoad(String asset) async {
    try {
      final bytes = await rootBundle.load(asset);
      return bytes.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }
}
