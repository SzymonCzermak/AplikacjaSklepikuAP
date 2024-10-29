import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:html' as html;
import 'dart:typed_data';

import '../utils/global_state.dart';
import '../models/gadzet.dart';

class SummaryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ogólne podsumowanie sprzedaży"),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final pdfData = await _generatePdf();
              _openPdfInNewTab(pdfData);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Całkowita suma sprzedaży: ${GlobalState.sumaSprzedazy.toStringAsFixed(2)} zł",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Divider(),
            Text(
              "Łączna wartość rabatów: ${GlobalState.sumaRabaty.toStringAsFixed(2)} zł",
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
            SizedBox(height: 10),
            Text(
              "Transakcje gotówką: ${GlobalState.liczbaTransakcjiGotowka} (suma: ${GlobalState.sumaGotowka.toStringAsFixed(2)} zł)",
              style: TextStyle(fontSize: 16),
            ),
            Text(
              "Transakcje kartą: ${GlobalState.liczbaTransakcjiKarta} (suma: ${GlobalState.sumaKarta.toStringAsFixed(2)} zł)",
              style: TextStyle(fontSize: 16),
            ),
            Divider(),
            Text(
              "Sprzedane gadżety:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...GlobalState.iloscGadzetow.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                "${entry.key}: ${entry.value} szt.",
                style: TextStyle(fontSize: 16),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();
    final fontData = await rootBundle.load("assets/gadzety/Fonts/arial.ttf");
    final ttf = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Ogólne podsumowanie sprzedaży", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, font: ttf)),
              pw.SizedBox(height: 10),
              pw.Text("Całkowita suma sprzedaży: ${GlobalState.sumaSprzedazy.toStringAsFixed(2)} zł", style: pw.TextStyle(fontSize: 18, font: ttf)),
              pw.Divider(),
              pw.Text("Łączna wartość rabatów: ${GlobalState.sumaRabaty.toStringAsFixed(2)} zł", style: pw.TextStyle(fontSize: 16, color: PdfColors.red, font: ttf)),
              pw.SizedBox(height: 10),
              pw.Text("Transakcje gotówką: ${GlobalState.liczbaTransakcjiGotowka} (suma: ${GlobalState.sumaGotowka.toStringAsFixed(2)} zł)", style: pw.TextStyle(font: ttf)),
              pw.Text("Transakcje kartą: ${GlobalState.liczbaTransakcjiKarta} (suma: ${GlobalState.sumaKarta.toStringAsFixed(2)} zł)", style: pw.TextStyle(font: ttf)),
              pw.Divider(),
              pw.Text("Sprzedane gadżety:", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, font: ttf)),
              ...GlobalState.iloscGadzetow.entries.map((entry) => pw.Text("${entry.key}: ${entry.value} szt.", style: pw.TextStyle(fontSize: 16, font: ttf))),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  void _openPdfInNewTab(Uint8List pdfData) {
    final blob = html.Blob([pdfData], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');
    html.Url.revokeObjectUrl(url);
  }
}
