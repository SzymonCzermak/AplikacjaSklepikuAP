import 'package:flutter/material.dart';
import '../models/gadzet.dart';
import '../utils/global_state.dart';
import 'home_page.dart';

class PaymentScreen extends StatelessWidget {
  final List<Gadzet> koszyk;

  PaymentScreen({required this.koszyk});

  void finalizeTransaction(String metodaPlatnosci, BuildContext context) {
    double suma = 0;
    double sumaRabatyTransakcji = 0; // Suma rabatów dla tej konkretnej transakcji
    Map<String, int> koszykZliczanie = {};

    // Zlicza liczbę egzemplarzy każdego gadżetu w koszyku
    koszyk.forEach((gadzet) {
      koszykZliczanie[gadzet.nazwa] = (koszykZliczanie[gadzet.nazwa] ?? 0) + 1;
    });

    koszykZliczanie.forEach((nazwa, ilosc) {
      Gadzet gadzet = koszyk.firstWhere((item) => item.nazwa == nazwa);

      // Rabat tylko na jeden egzemplarz, reszta w pełnej cenie
      if (gadzet.licznikZnizki > 0 && ilosc > 0) {
        double cenaPoRabacie = (gadzet.cena * 0.9).floorToDouble();
        suma += cenaPoRabacie + (ilosc - 1) * gadzet.cena;
        sumaRabatyTransakcji += gadzet.cena - cenaPoRabacie;
      } else {
        suma += gadzet.cena * ilosc;
      }
    });

    // Dodajemy sumę rabatów tej transakcji do globalnej sumy rabatów
    GlobalState.sumaRabaty += sumaRabatyTransakcji;

    // Aktualizuj wartości globalne
    GlobalState.sumaSprzedazy += suma;

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

    // Resetowanie rabatów po transakcji, aby można było je naliczyć w przyszłych transakcjach
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
    // Zlicza liczbę każdego gadżetu w koszyku
    Map<String, int> koszykZliczanie = {};
    koszyk.forEach((gadzet) {
      koszykZliczanie[gadzet.nazwa] = (koszykZliczanie[gadzet.nazwa] ?? 0) + 1;
    });

    double lacznaKwotaPoRabacie = koszykZliczanie.entries.fold(0.0, (sum, entry) {
      Gadzet gadzet = koszyk.firstWhere((item) => item.nazwa == entry.key);
      int ilosc = entry.value;

      // Rabat na jeden egzemplarz, pełna cena dla pozostałych
      double cenaPoRabacie = gadzet.licznikZnizki > 0
          ? (gadzet.cena * 0.9).floorToDouble() + (ilosc - 1) * gadzet.cena
          : gadzet.cena * ilosc;

      return sum + cenaPoRabacie;
    });

    return Scaffold(
      appBar: AppBar(title: Text("Wybierz sposób płatności")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                itemCount: koszykZliczanie.length,
                itemBuilder: (context, index) {
                  String nazwa = koszykZliczanie.keys.elementAt(index);
                  int ilosc = koszykZliczanie[nazwa]!;
                  Gadzet gadzet = koszyk.firstWhere((item) => item.nazwa == nazwa);
                  double rabat = gadzet.licznikZnizki > 0 ? gadzet.cena * 0.1 : 0.0;

                  return ListTile(
                    title: Text(gadzet.nazwa),
                    subtitle: Text(
                      "Cena: ${gadzet.cena.toStringAsFixed(2)} zł" +
                          (rabat > 0 ? " (Rabat: -${rabat.toStringAsFixed(2)} zł)" : ""),
                    ),
                    trailing: Text("Ilość: $ilosc"),
                  );
                },
              ),
            ),
            Divider(),
            Text(
              "Łączna kwota po rabacie: ${lacznaKwotaPoRabacie.toStringAsFixed(2)} zł",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.credit_card),
                  onPressed: () => finalizeTransaction("Karta", context),
                  label: Text("Płatność kartą"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                    backgroundColor: Colors.blueAccent,
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: Icon(Icons.money),
                  onPressed: () => finalizeTransaction("Gotówka", context),
                  label: Text("Płatność gotówką"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                    backgroundColor: Colors.green,
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
