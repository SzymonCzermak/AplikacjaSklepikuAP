import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

import '../utils/global_state.dart';

class TransactionsSummaryScreen extends StatefulWidget {
  @override
  _TransactionsSummaryScreenState createState() =>
      _TransactionsSummaryScreenState();
}

class _TransactionsSummaryScreenState extends State<TransactionsSummaryScreen> {
  final pdf = pw.Document();
  late String currentTime;

  @override
  void initState() {
    super.initState();
    _updateTime();
  }

  void _updateTime() {
    setState(() {
      currentTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    });
    Future.delayed(Duration(seconds: 1), _updateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Podsumowanie Transakcji"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: _generatePdfForWeb, // Generowanie PDF dla Web
            tooltip: "Pobierz jako PDF",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Podsumowanie Sprzedaży",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Aktualna data i godzina: $currentTime",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildTransactionGroup(
                    title: "Transakcje za Gotówkę",
                    transactions: GlobalState.gotowkaTransactions,
                    totalAmount: GlobalState.sumaGotowka,
                    totalDiscount: GlobalState.sumaRabatyGotowka,
                    color: Colors.green[100]!,
                    borderColor: Colors.green[600]!,
                  ),
                  SizedBox(height: 16),
                  _buildTransactionGroup(
                    title: "Transakcje za Kartę",
                    transactions: GlobalState.kartaTransactions,
                    totalAmount: GlobalState.sumaKarta,
                    totalDiscount: GlobalState.sumaRabatyKarta,
                    color: Colors.blue[100]!,
                    borderColor: Colors.blue[600]!,
                  ),
                  SizedBox(height: 16),
                  _buildTransactionGroup(
                    title: "Ogólne Transakcje",
                    transactions: _mergeTransactions(),
                    totalAmount:
                        GlobalState.sumaGotowka + GlobalState.sumaKarta,
                    totalDiscount: GlobalState.sumaRabatyGotowka +
                        GlobalState.sumaRabatyKarta,
                    color: Colors.red[100]!,
                    borderColor: Colors.red[600]!,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Merges gotówka and karta transactions and adds a `metodaPlatnosci` field.
  List<Map<String, dynamic>> _mergeTransactions() {
    return [
      ...GlobalState.gotowkaTransactions.map((transaction) {
        return {
          ...transaction,
          'metodaPlatnosci': 'Gotówka',
        };
      }),
      ...GlobalState.kartaTransactions.map((transaction) {
        return {
          ...transaction,
          'metodaPlatnosci': 'Karta',
        };
      }),
    ];
  }

  Widget _buildTransactionGroup({
    required String title,
    required List<Map<String, dynamic>> transactions,
    required double totalAmount,
    required double totalDiscount,
    required Color color,
    required Color borderColor,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: borderColor,
              ),
            ),
            SizedBox(height: 8),
            transactions.isEmpty
                ? Text(
                    "Brak transakcji.",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  )
                : Column(
                    children: List.generate(
                      transactions.length,
                      (index) => _buildTransactionCard(
                        transaction: transactions[index],
                        index: index + 1,
                        borderColor: borderColor,
                        showMethod: title == "Ogólne Transakcje",
                      ),
                    ),
                  ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Łączna Kwota:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("${totalAmount.toStringAsFixed(2)} zł"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Łączne Rabaty:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("-${totalDiscount.toStringAsFixed(2)} zł"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Liczba Transakcji:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("${transactions.length}"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard({
    required Map<String, dynamic> transaction,
    required int index,
    required Color borderColor,
    bool showMethod = false,
  }) {
    Color cardColor = transaction['metodaPlatnosci'] == 'Gotówka'
        ? Colors.green[50]!
        : Colors.blue[50]!;
    Color textColor = transaction['metodaPlatnosci'] == 'Gotówka'
        ? Colors.green[900]!
        : Colors.blue[900]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Transakcja #$index",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  transaction['gadzet'],
                  style: TextStyle(color: textColor),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  "Ilość: ${transaction['ilosc']}",
                  textAlign: TextAlign.right,
                  style: TextStyle(color: textColor),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  "Kwota: ${transaction['kwota'].toStringAsFixed(2)} zł",
                  textAlign: TextAlign.right,
                  style: TextStyle(color: textColor),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  "Rabat: -${transaction['rabat'].toStringAsFixed(2)} zł",
                  textAlign: TextAlign.right,
                  style: TextStyle(color: textColor),
                ),
              ),
            ],
          ),
          if (showMethod)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Metoda Płatności: ${transaction['metodaPlatnosci']}",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _generatePdfForWeb() async {
    final pdf = pw.Document();

    final fontData = await rootBundle.load('assets/gadzety/Fonts/arial.ttf');
    final ttf = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Podsumowanie Transakcji",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  font: ttf,
                ),
              ),
              pw.Text(
                "Data i godzina: $currentTime",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.normal,
                  font: ttf,
                ),
              ),
              pw.SizedBox(height: 20),
              _buildPdfTransactionSection(
                title: "Transakcje za Gotówkę",
                transactions: GlobalState.gotowkaTransactions,
                totalAmount: GlobalState.sumaGotowka,
                totalDiscount: GlobalState.sumaRabatyGotowka,
                font: ttf,
              ),
              pw.SizedBox(height: 20),
              _buildPdfTransactionSection(
                title: "Transakcje za Kartę",
                transactions: GlobalState.kartaTransactions,
                totalAmount: GlobalState.sumaKarta,
                totalDiscount: GlobalState.sumaRabatyKarta,
                font: ttf,
              ),
              pw.SizedBox(height: 20),
              _buildPdfTransactionSection(
                title: "Ogólne Transakcje",
                transactions: _mergeTransactions(),
                totalAmount: GlobalState.sumaGotowka + GlobalState.sumaKarta,
                totalDiscount:
                    GlobalState.sumaRabatyGotowka + GlobalState.sumaRabatyKarta,
                font: ttf,
              ),
            ],
          );
        },
      ),
    );

    final pdfBytes = await pdf.save();

    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..target = 'blank'
      ..download = 'transactions_summary.pdf'
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  pw.Widget _buildPdfTransactionSection({
    required String title,
    required List<Map<String, dynamic>> transactions,
    required double totalAmount,
    required double totalDiscount,
    required pw.Font font,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            font: font,
          ),
        ),
        pw.SizedBox(height: 10),
        if (transactions.isEmpty)
          pw.Text(
            "Brak transakcji.",
            style:
                pw.TextStyle(fontSize: 14, color: PdfColors.grey, font: font),
          )
        else
          pw.Table(
            border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text("Gadżet",
                        style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            font: font)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text("Ilość",
                        style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            font: font)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text("Kwota",
                        style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            font: font)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text("Rabat",
                        style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            font: font)),
                  ),
                ],
              ),
              ...transactions.map(
                (transaction) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(transaction['gadzet'] ?? '',
                          style: pw.TextStyle(fontSize: 12, font: font)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(transaction['ilosc'].toString(),
                          style: pw.TextStyle(fontSize: 12, font: font)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        "${transaction['kwota'].toStringAsFixed(2)} zł",
                        style: pw.TextStyle(fontSize: 12, font: font),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        "-${transaction['rabat'].toStringAsFixed(2)} zł",
                        style: pw.TextStyle(
                            fontSize: 12, color: PdfColors.red, font: font),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        pw.SizedBox(height: 10),
        pw.Text(
          "Łączna Kwota: ${totalAmount.toStringAsFixed(2)} zł",
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            font: font,
          ),
        ),
        pw.Text(
          "Łączne Rabaty: -${totalDiscount.toStringAsFixed(2)} zł",
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.red,
            font: font,
          ),
        ),
      ],
    );
  }
}
