import 'package:flutter/material.dart';
import '../models/gadzet.dart';
import 'payment_screen.dart';
import 'package:aplikacjasklepikuap/utils/global_state.dart';

class KoszykWidget extends StatelessWidget {
  final Map<String, int> iloscDoZakupu;
  final List<Gadzet> gadzety;
  final Map<String, bool> rabatUzyty;

  KoszykWidget({
    required this.iloscDoZakupu,
    required this.gadzety,
    required this.rabatUzyty,
  });

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> koszyk = gadzety
        .where((gadzet) =>
            iloscDoZakupu[gadzet.nazwa] != null &&
            iloscDoZakupu[gadzet.nazwa]! > 0)
        .map((gadzet) {
      double cena = gadzet.cena;
      int ilosc = iloscDoZakupu[gadzet.nazwa] ?? 0;

      // Sprawdź, czy rabat jest użyty
      bool rabat = rabatUzyty[gadzet.nazwa] ?? false;

      // Rabat naliczany tylko na pierwszą sztukę
      double rabatKwota = rabat && ilosc > 0 ? gadzet.rabat : 0.0;
      double cenaPoRabacie = rabat ? (cena - rabatKwota) : cena;

      // Cena całkowita
      double cenaCalkowita = cenaPoRabacie + (ilosc - 1) * cena;

      return {
        "nazwa": gadzet.nazwa,
        "ilosc": ilosc,
        "cena": cena,
        "rabat": rabat,
        "rabatKwota": rabatKwota,
        "cenaCalkowita": cenaCalkowita,
      };
    }).toList();

    double suma = koszyk.fold(0.0, (sum, item) => sum + item["cenaCalkowita"]);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Twój koszyk",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 12),
            koszyk.isEmpty
                ? Center(
                    child: Text(
                      "Koszyk jest pusty!",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : Column(
                    children: koszyk
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    item["nazwa"],
                                    style: TextStyle(fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "x${item["ilosc"]}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "${item["cenaCalkowita"].toStringAsFixed(2)} zł",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      if (item["rabatKwota"] > 0)
                                        Text(
                                          "-${item["rabatKwota"].toStringAsFixed(2)} zł (Rabat na 1 sztukę)",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.green[700],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
            SizedBox(height: 16),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Łącznie:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  Text(
                    "${suma.toStringAsFixed(2)} zł",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Zamknij",
                    style: TextStyle(color: Colors.redAccent, fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: koszyk.isEmpty
                      ? null
                      : () {
                          List<Gadzet> koszykGadzety = [];
                          iloscDoZakupu.forEach((nazwa, ilosc) {
                            if (ilosc > 0) {
                              final gadzet =
                                  gadzety.firstWhere((g) => g.nazwa == nazwa);
                              for (int i = 0; i < ilosc; i++) {
                                koszykGadzety.add(gadzet);
                              }
                            }
                          });

                          Navigator.pop(context); // Zamknięcie koszyka
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentScreen(
                                koszyk: koszykGadzety,
                                rabatUzyty:
                                    rabatUzyty, // Przekazanie mapy rabatUzyty
                              ),
                            ),
                          );
                        },
                  child: Text("Do płatności"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
