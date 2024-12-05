import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:intl/intl.dart';

import '../utils/global_state.dart';
import '../models/gadzet.dart';

class SummaryPage extends StatefulWidget {
  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  final String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // Dodano kontrolery tekstowe dla sum
  final TextEditingController sumaSprzedazyController =
      TextEditingController(text: GlobalState.sumaSprzedazy.toStringAsFixed(2));
  final TextEditingController sumaRabatyController =
      TextEditingController(text: GlobalState.sumaRabaty.toStringAsFixed(2));
  final TextEditingController sumaGotowkaController =
      TextEditingController(text: GlobalState.sumaGotowka.toStringAsFixed(2));
  final TextEditingController sumaKartaController =
      TextEditingController(text: GlobalState.sumaKarta.toStringAsFixed(2));
  final TextEditingController sumaParagonController =
      TextEditingController(text: GlobalState.sumaParagon.toStringAsFixed(2));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Podsumowanie sprzedaży z dnia $formattedDate",
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
            _editableSummaryRow(
                "Całkowita suma sprzedaży", sumaSprzedazyController),
            Divider(),
            _editableSummaryRow("Łączna wartość rabatów", sumaRabatyController,
                color: Colors.red),
            SizedBox(height: 20),
            _sectionHeader("Szczegóły Transakcji"),
            _editableSummaryRow("Transakcje gotówką", sumaGotowkaController),
            _editableSummaryRow("Transakcje kartą", sumaKartaController),
            _editableSummaryRow("Transakcje z paragonem", sumaParagonController,
                color: Colors.blue),
            Divider(),
            _sectionHeader("Sprzedane Gadżety"),
            SizedBox(height: 10),
            ...GlobalState.iloscGadzetow.entries.map((entry) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${entry.key}: ${entry.value} szt.",
                      style: TextStyle(fontSize: 16),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              if (entry.value > 0) {
                                GlobalState.iloscGadzetow[entry.key] =
                                    entry.value - 1;
                              }
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: Colors.green),
                          onPressed: () {
                            setState(() {
                              GlobalState.iloscGadzetow[entry.key] =
                                  entry.value + 1;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
    );
  }

  Widget _editableSummaryRow(String label, TextEditingController controller,
      {Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(
            width: 100, // szerokość pola tekstowego
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: TextStyle(
                  fontSize: 16, color: color, fontWeight: FontWeight.bold),
              onChanged: (value) {
                setState(() {
                  double parsedValue = double.tryParse(value) ?? 0.0;
                  if (label == "Całkowita suma sprzedaży") {
                    GlobalState.sumaSprzedazy = parsedValue;
                  } else if (label == "Łączna wartość rabatów") {
                    GlobalState.sumaRabaty = parsedValue;
                  } else if (label.contains("gotówką")) {
                    GlobalState.sumaGotowka = parsedValue;
                  } else if (label.contains("kartą")) {
                    GlobalState.sumaKarta = parsedValue;
                  } else if (label.contains("paragonem")) {
                    GlobalState.sumaParagon = parsedValue;
                  }
                });
              },
            ),
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
              pw.Text(
                "Ogólne Podsumowanie Sprzedaży - $formattedDate",
                style: pw.TextStyle(
                    fontSize: 22, fontWeight: pw.FontWeight.bold, font: ttf),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                  "Całkowita suma sprzedaży: ${GlobalState.sumaSprzedazy.toStringAsFixed(2)} zł",
                  style: pw.TextStyle(fontSize: 18, font: ttf)),
              pw.Divider(),
              pw.Text(
                  "Łączna wartość rabatów: ${GlobalState.sumaRabaty.toStringAsFixed(2)} zł",
                  style: pw.TextStyle(
                      fontSize: 16, color: PdfColors.red, font: ttf)),
              pw.SizedBox(height: 10),
              pw.Text(
                  "Transakcje gotówką: ${GlobalState.liczbaTransakcjiGotowka} (suma: ${GlobalState.sumaGotowka.toStringAsFixed(2)} zł)",
                  style: pw.TextStyle(font: ttf)),
              pw.Text(
                  "Transakcje kartą: ${GlobalState.liczbaTransakcjiKarta} (suma: ${GlobalState.sumaKarta.toStringAsFixed(2)} zł)",
                  style: pw.TextStyle(font: ttf)),
              pw.Text(
                  "Transakcje z paragonem: ${GlobalState.liczbaTransakcjiParagon} (suma: ${GlobalState.sumaParagon.toStringAsFixed(2)} zł)",
                  style: pw.TextStyle(color: PdfColors.blue, font: ttf)),
              pw.Divider(),
              pw.Text("Sprzedane Gadżety:",
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold, font: ttf)),
              ...GlobalState.iloscGadzetow.entries.map((entry) => pw.Text(
                  "${entry.key}: ${entry.value} szt.",
                  style: pw.TextStyle(fontSize: 16, font: ttf))),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  void _openPdfInNewTab(Uint8List pdfData) {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);
    final blob = html.Blob([pdfData], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "Sprzedaz_$formattedDate.pdf")
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
