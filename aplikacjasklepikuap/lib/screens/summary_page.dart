import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:intl/intl.dart';

import '../utils/global_state.dart';
import '../models/gadzet.dart';

class SummaryPage extends StatelessWidget {

String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Podsumowanie sprzedazy k12 z dnia $formattedDate.", // Dodano datę
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
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
            _sectionHeader("Podsumowanie"),
            _summaryRow("Całkowita suma sprzedaży", "${GlobalState.sumaSprzedazy.toStringAsFixed(2)} zł"),
            Divider(),
            _summaryRow(
              "Łączna wartość rabatów",
              "${GlobalState.sumaRabaty.toStringAsFixed(2)} zł",
              color: Colors.red,
            ),
            SizedBox(height: 20),
            _sectionHeader("Szczegóły Transakcji"),
            _summaryRow("Transakcje gotówką", "${GlobalState.liczbaTransakcjiGotowka} (suma: ${GlobalState.sumaGotowka.toStringAsFixed(2)} zł)"),
            _summaryRow("Transakcje kartą", "${GlobalState.liczbaTransakcjiKarta} (suma: ${GlobalState.sumaKarta.toStringAsFixed(2)} zł)"),
            Divider(),
            _sectionHeader("Sprzedane Gadżety"),
            SizedBox(height: 10),
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

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
    );
  }

  Widget _summaryRow(String label, String value, {Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.bold),
          ),
        ],
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
              pw.Text("Ogólne Podsumowanie Sprzedaży", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, font: ttf)),
              pw.SizedBox(height: 10),
              pw.Text("Całkowita suma sprzedaży: ${GlobalState.sumaSprzedazy.toStringAsFixed(2)} zł", style: pw.TextStyle(fontSize: 18, font: ttf)),
              pw.Divider(),
              pw.Text("Łączna wartość rabatów: ${GlobalState.sumaRabaty.toStringAsFixed(2)} zł", style: pw.TextStyle(fontSize: 16, color: PdfColors.red, font: ttf)),
              pw.SizedBox(height: 10),
              pw.Text("Transakcje gotówką: ${GlobalState.liczbaTransakcjiGotowka} (suma: ${GlobalState.sumaGotowka.toStringAsFixed(2)} zł)", style: pw.TextStyle(font: ttf)),
              pw.Text("Transakcje kartą: ${GlobalState.liczbaTransakcjiKarta} (suma: ${GlobalState.sumaKarta.toStringAsFixed(2)} zł)", style: pw.TextStyle(font: ttf)),
              pw.Divider(),
              pw.Text("Sprzedane Gadżety:", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, font: ttf)),
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
