import 'package:flutter/material.dart';
import '../models/gadzet.dart';
import '../utils/global_state.dart';
import 'home_page.dart';

class PaymentScreen extends StatelessWidget {
  final List<Gadzet> koszyk;

  PaymentScreen({required this.koszyk});

  void finalizeTransaction(String metodaPlatnosci, BuildContext context) {
    double suma = 0;
    double sumaRabaty = 0;
    Map<String, int> koszykZliczanie = {};

    // Zlicza liczbę egzemplarzy każdego gadżetu w koszyku
    koszyk.forEach((gadzet) {
      koszykZliczanie[gadzet.nazwa] = (koszykZliczanie[gadzet.nazwa] ?? 0) + 1;
    });

    // Wylicza łączną cenę uwzględniając zniżki i nalicza sumę rabatów
    koszykZliczanie.forEach((nazwa, ilosc) {
      Gadzet gadzet = koszyk.firstWhere((item) => item.nazwa == nazwa);
      suma += gadzet.getCenaZRabatem(ilosc);

      if (gadzet.licznikZnizki > 0) {
        double cenaPoRabacie = (gadzet.cena * 0.9).floorToDouble();
        double rabatNaSztuke = gadzet.cena - cenaPoRabacie;
        sumaRabaty += rabatNaSztuke;
      }
    });

    // Zaktualizuj wartości globalne
    GlobalState.sumaSprzedazy += suma;
    GlobalState.sumaRabaty += sumaRabaty;
    if (metodaPlatnosci == "Gotówka") {
      GlobalState.liczbaTransakcjiGotowka++;
      GlobalState.sumaGotowka += suma;
    } else {
      GlobalState.liczbaTransakcjiKarta++;
      GlobalState.sumaKarta += suma;
    }

    koszyk.forEach((gadzet) {
      GlobalState.iloscGadzetow[gadzet.nazwa] = (GlobalState.iloscGadzetow[gadzet.nazwa] ?? 0) + 1;
    });

    koszyk.forEach((gadzet) {
      gadzet.licznikZnizki = 0;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Wybierz sposób płatności")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Sekcja podsumowania koszyka
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Podsumowanie Koszyka",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: koszyk.length,
                      itemBuilder: (context, index) {
                        final gadzet = koszyk[index];
                        final rabat = gadzet.licznikZnizki > 0
                            ? (gadzet.cena - (gadzet.cena * 0.9).floorToDouble())
                            : 0.0;
                        return ListTile(
                          title: Text(gadzet.nazwa),
                          subtitle: Text("Cena: ${gadzet.cena.toStringAsFixed(2)} zł" +
                              (rabat > 0 ? " (Rabat: -${rabat.toStringAsFixed(2)} zł)" : "")),
                          trailing: Text("Ilość: ${koszyk.where((g) => g.nazwa == gadzet.nazwa).length}"),
                        );
                      },
                    ),
                  ),
                  Divider(),
                  Text(
                    "Łączna kwota: ${koszyk.fold(0.0, (double sum, gadzet) => sum + gadzet.cena).toStringAsFixed(2)} zł",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            VerticalDivider(),
            // Sekcja wyboru płatności
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.credit_card),
                    onPressed: () => finalizeTransaction("Karta", context),
                    label: Text("Płatność kartą"),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30), backgroundColor: Colors.blueAccent,
                      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: Icon(Icons.money),
                    onPressed: () => finalizeTransaction("Gotówka", context),
                    label: Text("Płatność gotówką"),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30), backgroundColor: Colors.green,
                      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


