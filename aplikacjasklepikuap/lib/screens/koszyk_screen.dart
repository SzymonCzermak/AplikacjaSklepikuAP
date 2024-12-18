import 'package:flutter/material.dart';
import '../models/gadzet.dart';
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
      double cena = gadzet.cena ?? 0.0;
      int ilosc = iloscDoZakupu[gadzet.nazwa] ?? 0;

      // Oblicz rabat
      bool rabat = rabatUzyty[gadzet.nazwa] ?? false;
      double rabatKwota = rabat
          ? (cena * 0.1 >= 1 ? (cena * 0.1).floorToDouble() : cena * 0.1)
          : 0.0;

      // Cena całkowita
      double cenaCalkowita = (ilosc * cena) - rabatKwota;

      return {
        "nazwa": gadzet.nazwa,
        "ilosc": ilosc,
        "cena": cena,
        "rabat": rabat,
        "rabatKwota": rabatKwota,
        "cenaCalkowita": cenaCalkowita.toInt(),
      };
    }).toList();

    double suma = koszyk.fold(0, (sum, item) => sum + item["cenaCalkowita"]);

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
                                  flex: 2,
                                  child: Text(
                                    "${item["cenaCalkowita"].toStringAsFixed(2)} zł",
                                    textAlign: TextAlign.right,
                                    style: TextStyle(fontSize: 16),
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
                  onPressed: () {
                    double sumaTransakcji = 0.0;
                    double sumaRabatyTransakcji = 0.0;

                    koszyk.forEach((item) {
                      String nazwa = item['nazwa'];
                      int ilosc = item['ilosc'];
                      double cena = item['cena'];
                      double rabatKwota = item['rabatKwota'];

                      // Aktualizacja sprzedanych gadżetów
                      if (GlobalState.sprzedaneGadzety.containsKey(nazwa)) {
                        GlobalState.sprzedaneGadzety[nazwa] =
                            GlobalState.sprzedaneGadzety[nazwa]! + ilosc;
                      } else {
                        GlobalState.sprzedaneGadzety[nazwa] = ilosc;
                      }

                      // Dodanie do sumy transakcji
                      sumaTransakcji += (ilosc * cena) - rabatKwota;
                      sumaRabatyTransakcji += rabatKwota;
                    });

                    // Aktualizacja globalnych wartości
                    GlobalState.sumaSprzedazy =
                        sumaTransakcji; // Precyzyjna suma
                    GlobalState.sumaRabaty = sumaRabatyTransakcji;

                    // Czyszczenie koszyka
                    iloscDoZakupu.clear();

                    // Zamknięcie dialogu
                    Navigator.pop(context);
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
