import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  // final TextEditingController sumaSprzedazyController =
  //     TextEditingController(text: GlobalState.sumaSprzedazy.toStringAsFixed(2));
  // final TextEditingController sumaRabatyController =
  //     TextEditingController(text: GlobalState.sumaRabaty.toStringAsFixed(2));
  final TextEditingController sumaGotowkaController =
      TextEditingController(text: GlobalState.sumaGotowka.toStringAsFixed(2));
  final TextEditingController sumaKartaController =
      TextEditingController(text: GlobalState.sumaKarta.toStringAsFixed(2));
  final TextEditingController sumaParagonController =
      TextEditingController(text: GlobalState.sumaParagon.toStringAsFixed(2));

  @override
  Widget build(BuildContext context) {
    @override
    void didChangeDependencies() {
      super.didChangeDependencies();
      setState(() {}); // Odświeżenie widoku
    }

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
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Całkowita suma sprzedaży:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  "${GlobalState.sumaSprzedazy.toStringAsFixed(2)} zł",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Łączna wartość rabatów:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  "${GlobalState.sumaRabaty.toStringAsFixed(2)} zł",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _sectionHeader("Szczegóły Transakcji"),
            _editableSummaryRow("Transakcje gotówką", sumaGotowkaController),
            _editableSummaryRow("Transakcje kartą", sumaKartaController),
            _editableSummaryRow("Transakcje z paragonem", sumaParagonController,
                color: Colors.blue),
            Divider(),
            _sectionHeader("Sprzedane Gadżety"),
            SizedBox(height: 10),
            if (GlobalState.sprzedaneGadzety.isNotEmpty)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Nazwa Gadżetu",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      Text(
                        "Ilość",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                    ],
                  ),
                  Divider(thickness: 1.5, color: Colors.grey[300]),
                  ...GlobalState.sprzedaneGadzety.entries
                      .map((entry) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black87),
                                ),
                                Text(
                                  "${entry.value} szt.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          )),
                  Divider(thickness: 1.5, color: Colors.grey[300]),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _saveSummaryToFirebase();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Zakończ Dzień",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )
            else
              Center(
                child: Text(
                  "Brak sprzedanych gadżetów.",
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
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

//funkcja do zakonczenia dnia i dodania informacji do bazy danych
  Future<void> _saveSummaryToFirebase() async {
    try {
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd').format(now);

      // Tworzymy obiekt danych do zapisania
      Map<String, dynamic> summaryData = {
        'date': formattedDate,
        'sumaSprzedazy': GlobalState.sumaSprzedazy,
        'sumaRabaty': GlobalState.sumaRabaty,
        'sumaGotowka': GlobalState.sumaGotowka,
        'sumaKarta': GlobalState.sumaKarta,
        'sumaParagon': GlobalState.sumaParagon,
        'sprzedaneGadzety': GlobalState.sprzedaneGadzety,
      };

      // Zapisujemy dane do Firestore
      await FirebaseFirestore.instance
          .collection('summaryReports')
          .add(summaryData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dane zostały zapisane do bazy danych!')),
      );

      // Resetowanie strony po zapisaniu danych
      _resetSummaryPage();
    } catch (e) {
      print("Błąd podczas zapisywania do Firestore: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wystąpił błąd podczas zapisywania danych.')),
      );
    }
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
                "Podsumowanie sprzedaży - $formattedDate",
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  font: ttf,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                "Całkowita suma sprzedaży: ${GlobalState.sumaSprzedazy.toStringAsFixed(2)} zł",
                style: pw.TextStyle(fontSize: 18, font: ttf),
              ),
              pw.Text(
                "Łączna wartość rabatów: ${GlobalState.sumaRabaty.toStringAsFixed(2)} zł",
                style: pw.TextStyle(
                  fontSize: 16,
                  font: ttf,
                  color: PdfColors.red,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 1, color: PdfColors.grey),
              pw.Text(
                "Sprzedane Gadżety:",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  font: ttf,
                ),
              ),
              pw.SizedBox(height: 8),
              if (GlobalState.sprzedaneGadzety.isNotEmpty)
                pw.Table(
                  border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
                  children: [
                    // Nagłówki tabeli
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text("Nazwa Gadżetu",
                              style: pw.TextStyle(
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold,
                                  font: ttf)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text("Ilość",
                              style: pw.TextStyle(
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold,
                                  font: ttf)),
                        ),
                      ],
                    ),
                    // Dane z GlobalState
                    ...GlobalState.sprzedaneGadzety.entries.map(
                      (entry) => pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(entry.key,
                                style: pw.TextStyle(fontSize: 14, font: ttf)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text("${entry.value} szt.",
                                style: pw.TextStyle(fontSize: 14, font: ttf)),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                pw.Text(
                  "Brak sprzedanych gadżetów.",
                  style: pw.TextStyle(
                      fontSize: 14, fontStyle: pw.FontStyle.italic, font: ttf),
                ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  void _resetSummaryPage() {
    setState(() {
      // Resetowanie wszystkich wartości w GlobalState
      GlobalState.sumaSprzedazy = 0.0;
      GlobalState.sumaRabaty = 0.0;
      GlobalState.sumaGotowka = 0.0;
      GlobalState.sumaKarta = 0.0;
      GlobalState.sumaParagon = 0.0;
      GlobalState.sprzedaneGadzety.clear();

      // Czyszczenie kontrolerów tekstowych
      sumaGotowkaController.text = "0.00";
      sumaKartaController.text = "0.00";
      sumaParagonController.text = "0.00";
    });
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
