import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // necessário para RenderRepaintBoundary
import 'package:path_provider/path_provider.dart';

class ReportCaptureController {
  final GlobalKey repaintKey = GlobalKey();

  /// Captura a área envolta por um RepaintBoundary usando [repaintKey]
  /// e salva como PNG no diretório temporário do app.
  Future<File> saveAsPng({
    String filename = 'effatha_report.png',
    double pixelRatio = 3.0,
  }) async {
    final boundary =
        repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw Exception(
        'RepaintBoundary not found. '
        'Garanta que o widget está renderizado e que você usou key: _capture.repaintKey.',
      );
    }

    final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Falha ao converter a imagem para PNG.');
    }

    final Uint8List bytes = byteData.buffer.asUint8List();
    final Directory dir = await getTemporaryDirectory();
    final File file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  /// Retorna apenas os bytes PNG (caso queira tratar o destino por conta própria).
  Future<Uint8List> captureBytes({double pixelRatio = 3.0}) async {
    final boundary =
        repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw Exception(
        'RepaintBoundary not found. '
        'Garanta que o widget está renderizado e que você usou key: _capture.repaintKey.',
      );
    }

    final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Falha ao converter a imagem para PNG.');
    }

    return byteData.buffer.asUint8List();
    }
}
