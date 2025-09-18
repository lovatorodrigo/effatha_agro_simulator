import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/report/report_service.dart';
import 'report_template_widget.dart';
import '../services/report/report_capture.dart';

/// Mantido por compatibilidade com a navegação tipada
class SimulationExportArgs {
  final Map<String, dynamic> traditional;
  final Map<String, dynamic> effatha;
  final String cropKey;
  final String areaUnit;          // 'hectares' | 'acres'
  final String productivityUnit;  // 'kg/ha' | 't/ha' | 'sc/ha' | 'sc/acre'
  final double kgPerSack;

  const SimulationExportArgs({
    required this.traditional,
    required this.effatha,
    required this.cropKey,
    required this.areaUnit,
    required this.productivityUnit,
    required this.kgPerSack,
  });
}

class ExportResultsScreen extends StatefulWidget {
  const ExportResultsScreen({super.key});

  @override
  State<ExportResultsScreen> createState() => _ExportResultsScreenState();
}

class _ExportResultsScreenState extends State<ExportResultsScreen> {
  final _capture = ReportCaptureController();
  double _kgPerSackFallback = 60.0;

  @override
  void initState() {
    super.initState();
    _loadKgPerSack();
  }

  Future<void> _loadKgPerSack() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final k = prefs.getDouble('kg_per_sack_weight');
      if (mounted && k != null && k > 0) {
        setState(() => _kgPerSackFallback = k);
      }
    } catch (_) {/* mantém 60.0 */}
  }

  @override
  Widget build(BuildContext context) {
    // Aceita SimulationExportArgs OU Map<String, dynamic>
    final raw = ModalRoute.of(context)?.settings.arguments;

    Map<String, dynamic>? traditional;
    Map<String, dynamic>? effatha;
    String cropKey = 'soy';
    String areaUnit = 'hectares';
    String productivityUnit = 'sc/ha';
    double kgPerSack = _kgPerSackFallback;

    if (raw is SimulationExportArgs) {
      traditional = raw.traditional;
      effatha = raw.effatha;
      cropKey = raw.cropKey;
      areaUnit = raw.areaUnit;
      productivityUnit = raw.productivityUnit;
      kgPerSack = raw.kgPerSack;
    } else if (raw is Map<String, dynamic>) {
      traditional = raw['traditional'] as Map<String, dynamic>?;
      effatha = raw['effatha'] as Map<String, dynamic>?;
      cropKey = (raw['cropKey'] as String?) ?? cropKey;

      final inputs = raw['inputs'] as Map<String, dynamic>?;
      if (inputs != null) {
        areaUnit = (inputs['areaUnit'] as String?) ?? areaUnit;
        productivityUnit = (inputs['productivityUnit'] as String?) ?? productivityUnit;
        final k = inputs['kgPerSack'];
        if (k is num && k > 0) kgPerSack = k.toDouble();
      }
    }

    if (traditional == null || effatha == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Export Report')),
        body: const Center(child: Text('No data received for export.')),
      );
    }

    final reportData = SimulationReportData(
      traditional: traditional,
      effatha: effatha,
      cropKey: cropKey,
      areaUnit: areaUnit,
      productivityUnit: productivityUnit,
      kgPerSack: kgPerSack,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Report'),
        actions: [
          IconButton(
            tooltip: 'Share as PNG',
            onPressed: () async {
              try {
                final file = await _capture.saveAsPng(
                  filename: 'effatha_report_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.png',
                );
                await Share.shareXFiles(
                  [XFile(file.path)],
                  text: 'Effatha Simulation Report',
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('PNG export failed: $e')),
                );
              }
            },
            icon: const Icon(Icons.image_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          // Preview do PDF
          Expanded(
            child: PdfPreview(
              canChangeOrientation: false,
              canChangePageFormat: false,
              initialPageFormat: PdfPageFormat.a4,
              build: (fmt) => ReportService.buildSimulationPdf(reportData),
            ),
          ),

          // Prévia PNG / Área de captura
          Container(
            height: 340,
            width: double.infinity,
            color: Colors.black12,
            child: RepaintBoundary(
              key: _capture.repaintKey,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: _ReportPreviewShell(),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final bytes = await ReportService.buildSimulationPdf(reportData);
          await Printing.sharePdf(
            bytes: bytes,
            filename: 'effatha_report_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf',
          );
        },
        icon: const Icon(Icons.picture_as_pdf_outlined),
        label: const Text('Share PDF'),
      ),
    );
  }
}

/// Wrapper só para ler o mesmo arguments que a tela recebeu e
/// montar o ReportTemplateWidget sem repetir parsing.
class _ReportPreviewShell extends StatelessWidget {
  const _ReportPreviewShell();

  @override
  Widget build(BuildContext context) {
    final raw = ModalRoute.of(context)?.settings.arguments;

    Map<String, dynamic>? traditional;
    Map<String, dynamic>? effatha;
    String cropKey = 'soy';
    String areaUnit = 'hectares';
    String productivityUnit = 'sc/ha';

    if (raw is SimulationExportArgs) {
      traditional = raw.traditional;
      effatha = raw.effatha;
      cropKey = raw.cropKey;
      areaUnit = raw.areaUnit;
      productivityUnit = raw.productivityUnit;
    } else if (raw is Map<String, dynamic>) {
      traditional = raw['traditional'] as Map<String, dynamic>?;
      effatha = raw['effatha'] as Map<String, dynamic>?;
      cropKey = (raw['cropKey'] as String?) ?? cropKey;
      final inputs = raw['inputs'] as Map<String, dynamic>?;
      if (inputs != null) {
        areaUnit = (inputs['areaUnit'] as String?) ?? areaUnit;
        productivityUnit = (inputs['productivityUnit'] as String?) ?? productivityUnit;
      }
    }

    return ReportTemplateWidget(
      traditional: traditional ?? const {},
      effatha: effatha ?? const {},
      cropKey: cropKey,
      areaUnit: areaUnit,
      productivityUnit: productivityUnit,
    );
  }
}
