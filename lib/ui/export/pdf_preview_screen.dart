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
class PdfPreviewScreen extends StatefulWidget {
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
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  // Load the fonts ONCE, up front — not inside PdfPreview's build callback.
  // On macOS the printing plugin's dynamic layout blocks the platform thread
  // waiting for the document to be (re)built; if that build in turn calls
  // rootBundle (which also needs the platform thread) the app deadlocks and the
  // whole window freezes on Print. Preloading here keeps the build callback off
  // the platform channel.
  late final Future<PdfFonts> _fonts = loadPdfFonts();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<PdfFonts>(
        future: _fonts,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Failed to load PDF fonts:\n${snap.error}',
                    textAlign: TextAlign.center),
              ),
            );
          }
          final fonts = snap.data!;
          return PdfPreview(
            pdfFileName: widget.fileName,
            canDebug: false,
            // Build the document once instead of re-laying-out per printer page
            // size. Dynamic layout blocks the macOS platform thread waiting for
            // a rebuild, which deadlocks the app on Print; a single static build
            // avoids that and is fine for these reports.
            dynamicLayout: false,
            build: (format) => widget.builder(fonts),
          );
        },
      ),
    );
  }
}
