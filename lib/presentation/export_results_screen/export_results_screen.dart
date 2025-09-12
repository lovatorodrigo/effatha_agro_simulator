import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart'; // para PdfPageFormat.a4
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/app_export.dart';
import '../services/report/report_service.dart';   // caminho correto
import 'report_template_widget.dart';
import '../services/report/report_capture.dart';  // caminho correto

class SimulationExportArgs {
  final Map<String, dynamic> traditional;
  final Map<String, dynamic> effatha;
  final String cropKey;
  final String areaUnit;          // 'hectares' | 'acres'
  final String productivityUnit;  // 'kg/ha' | 't/ha' | 'sacks/ha' | 'sacks/acre'
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

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as SimulationExportArgs?;

    if (args == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Export Report')),
        body: const Center(child: Text('No data received for export.')),
      );
    }

    final reportData = SimulationReportData(
      traditional: args.traditional,
      effatha: args.effatha,
      cropKey: args.cropKey,
      areaUnit: args.areaUnit,
      productivityUnit: args.productivityUnit,
      kgPerSack: args.kgPerSack,
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
                await Share.shareXFiles([XFile(file.path)], text: 'Effatha Simulation Report');
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
          Expanded(
            child: PdfPreview(
              canChangeOrientation: false,
              canChangePageFormat: false,
              initialPageFormat: PdfPageFormat.a4,
              // build espera uma função (PdfPageFormat) => Future<Uint8List>
              build: (fmt) => ReportService.buildSimulationPdf(reportData),
            ),
          ),
          // Prévia PNG / área de captura
          Container(
            height: 340,
            width: double.infinity,
            color: Colors.black12,
            child: RepaintBoundary(
              key: _capture.repaintKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ReportTemplateWidget(
                  traditional: args.traditional,
                  effatha: args.effatha,
                  cropKey: args.cropKey,
                  areaUnit: args.areaUnit,
                  productivityUnit: args.productivityUnit,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Compartilhar PDF
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
