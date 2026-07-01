import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../export/pdf_export.dart';

/// Loads the bundled Roboto fonts for PDF generation.
Future<PdfFonts> loadPdfFonts() async {
  final regular = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
  final bold = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));
  return PdfFonts(regular, bold);
}

/// Shows a generated PDF with print / share / save (download) actions.
class PdfPreviewScreen extends StatelessWidget {
  const PdfPreviewScreen({
    super.key,
    required this.title,
    required this.fileName,
    required this.builder,
  });

  final String title;
  final String fileName;
  final Future<Uint8List> Function(PdfFonts fonts) builder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PdfPreview(
        pdfFileName: fileName,
        canDebug: false,
        build: (format) async => builder(await loadPdfFonts()),
      ),
    );
  }
}
