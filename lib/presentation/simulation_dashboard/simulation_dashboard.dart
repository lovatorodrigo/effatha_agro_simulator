import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../routes/app_routes.dart';

class SimulationDashboard extends StatefulWidget {
  const SimulationDashboard({super.key});

  @override
  State<SimulationDashboard> createState() => _SimulationDashboardState();
}

class _SimulationDashboardState extends State<SimulationDashboard> {
  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Tenta carregar o logo. Se falhar, cai no texto.
            Image.asset(
              'assets/images/effatha_logo.png',
              height: 28,
              errorBuilder: (_, __, ___) => const Text('Effatha Agro Simulator'),
            ),
            const SizedBox(width: 12),
            const Text('Dashboard'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Configurações',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Resumo da Simulação',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    Text('Aqui vão os indicadores principais do seu cenário.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _exporting ? null : _exportPdf,
              icon: _exporting
                  ? const SizedBox(
                      width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.picture_as_pdf),
              label: Text(_exporting ? 'Gerando PDF...' : 'Exportar PDF'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportPdf() async {
    setState(() => _exporting = true);
    try {
      final doc = pw.Document();

      // Tenta carregar logo dos assets. Se não existir, segue sem logo.
      pw.MemoryImage? logo;
      try {
        final ByteData data = await rootBundle.load('assets/images/effatha_logo.png');
        final Uint8List bytes = data.buffer.asUint8List();
        logo = pw.MemoryImage(bytes);
      } catch (_) {
        logo = null;
      }

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (logo != null)
                  pw.Center(
                    child: pw.Image(logo, height: 60),
                  )
                else
                  pw.Text('Effatha Agro Simulator', style: pw.TextStyle(fontSize: 20)),
                pw.SizedBox(height: 16),
                pw.Text('Relatório da Simulação', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text('• Indicador 1: ...'),
                pw.Text('• Indicador 2: ...'),
                pw.Text('• Indicador 3: ...'),
                pw.SizedBox(height: 24),
                pw.Text('Gerado pelo app em ${DateTime.now()}'),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao gerar PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }
}
