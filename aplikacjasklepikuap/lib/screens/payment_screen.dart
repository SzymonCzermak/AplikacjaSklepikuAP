import 'package:flutter/material.dart';
import '../models/gadzet.dart';
import '../utils/global_state.dart';
import 'home_page.dart';

class PaymentScreen extends StatefulWidget {
  final List<Gadzet> koszyk;
  final Map<String, bool> rabatUzyty;

  PaymentScreen({required this.koszyk, required this.rabatUzyty});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool paragonWystawiony = false;

  double _sumaCalkowita = 0.0;
  double _sumaRabaty = 0.0;
  Map<String, int> _koszykZliczanie = {};

  /// Oblicza podsumowanie koszyka
  void _obliczPodsumowanie() {
    _sumaCalkowita = 0.0;
    _sumaRabaty = 0.0;
    _koszykZliczanie.clear();

    for (var gadzet in widget.koszyk) {
      _koszykZliczanie[gadzet.nazwa] =
          (_koszykZliczanie[gadzet.nazwa] ?? 0) + 1;
    }

    _koszykZliczanie.forEach((nazwa, ilosc) {
      final gadzet = widget.koszyk.firstWhere(
        (item) => item.nazwa == nazwa,
        orElse: () => Gadzet(
          nazwa: "Nieznany",
          cena: 0.0,
          obrazek: '',
          rabat: 0.0,
        ),
      );

      // Sprawdzenie, czy rabat był użyty
      bool rabatUzyty = widget.rabatUzyty[nazwa] ?? false;

      // Rabat naliczany tylko na jedną sztukę, jeśli został użyty
      double rabatNaJednostke = rabatUzyty ? gadzet.rabat : 0.0;
      double cenaPierwszegoZRabatem = gadzet.cena - rabatNaJednostke;

      // Obliczenia cen dla pozostałych egzemplarzy
      double cenaPozostalych = (ilosc - 1) * gadzet.cena;

      // Łączna cena dla tego produktu
      double lacznaCena = cenaPierwszegoZRabatem + cenaPozostalych;

      // Aktualizacja sum
      _sumaRabaty += rabatNaJednostke; // Rabat naliczany tylko raz, jeśli użyty
      _sumaCalkowita += lacznaCena;
    });
  }

  /// Finalizuje transakcję
  void _finalizeTransaction(String metodaPlatnosci) {
    double sumaField = metodaPlatnosci == "Gotówka"
        ? GlobalState.sumaGotowka
        : GlobalState.sumaKarta;

    double sumaRabatyField = metodaPlatnosci == "Gotówka"
        ? GlobalState.sumaRabatyGotowka
        : GlobalState.sumaRabatyKarta;

    sumaField += _sumaCalkowita;
    sumaRabatyField += _sumaRabaty;

    if (metodaPlatnosci == "Gotówka") {
      GlobalState.sumaGotowka = sumaField;
      GlobalState.sumaRabatyGotowka = sumaRabatyField;
    } else {
      GlobalState.sumaKarta = sumaField;
      GlobalState.sumaRabatyKarta = sumaRabatyField;
    }

    final transactionsList = metodaPlatnosci == "Gotówka"
        ? GlobalState.gotowkaTransactions
        : GlobalState.kartaTransactions;

    Map<String, Map<String, dynamic>> groupedTransactions = {};

    _koszykZliczanie.forEach((nazwa, ilosc) {
      final gadzet = widget.koszyk.firstWhere((item) => item.nazwa == nazwa);
      bool rabatUzyty = widget.rabatUzyty[nazwa] ?? false;
      double rabatNaJednostke = rabatUzyty ? gadzet.rabat : 0.0;
      double cenaPierwszegoZRabatem = gadzet.cena - rabatNaJednostke;
      double cenaPozostalych = (ilosc - 1) * gadzet.cena;

      double lacznaCena = cenaPierwszegoZRabatem + cenaPozostalych;

      if (groupedTransactions.containsKey(nazwa)) {
        groupedTransactions[nazwa]!['ilosc'] += ilosc;
        groupedTransactions[nazwa]!['kwota'] += lacznaCena;
        groupedTransactions[nazwa]!['rabat'] += rabatNaJednostke;
      } else {
        groupedTransactions[nazwa] = {
          'gadzet': nazwa,
          'ilosc': ilosc,
          'kwota': lacznaCena,
          'rabat': rabatNaJednostke,
        };
      }
    });

    groupedTransactions.values.forEach((transaction) {
      transactionsList.add(transaction);
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  void initState() {
    super.initState();
    _obliczPodsumowanie();
  }

  @override
  Widget build(BuildContext context) {
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
                itemCount: _koszykZliczanie.length,
                itemBuilder: (context, index) {
                  String nazwa = _koszykZliczanie.keys.elementAt(index);
                  int ilosc = _koszykZliczanie[nazwa]!;
                  Gadzet gadzet = widget.koszyk.firstWhere(
                    (item) => item.nazwa == nazwa,
                    orElse: () => Gadzet(
                      nazwa: "Nieznany",
                      cena: 0.0,
                      obrazek: '',
                      rabat: 0.0,
                    ),
                  );

                  bool rabatUzyty = widget.rabatUzyty[nazwa] ?? false;
                  double rabatNaJednostke = rabatUzyty ? gadzet.rabat : 0.0;
                  double cenaPoRabacie = gadzet.cena - rabatNaJednostke;
                  double lacznaCena = cenaPoRabacie + (ilosc - 1) * gadzet.cena;

                  return ListTile(
                    title: Text(gadzet.nazwa),
                    subtitle: Text(
                      "Cena jednostkowa: ${gadzet.cena.toStringAsFixed(2)} zł" +
                          (rabatNaJednostke > 0
                              ? " (Rabat: -${rabatNaJednostke.toStringAsFixed(2)} zł)"
                              : ""),
                    ),
                    trailing: Text(
                      "x$ilosc = ${lacznaCena.toStringAsFixed(2)} zł",
                    ),
                  );
                },
              ),
            ),
            Divider(),
            Text(
              "Łączna kwota: ${_sumaCalkowita.toStringAsFixed(2)} zł",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              "Zaoszczędzono: ${_sumaRabaty.toStringAsFixed(2)} zł",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.credit_card),
                  onPressed: () => _finalizeTransaction("Karta"),
                  label: Text("Płatność kartą"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                    backgroundColor: Colors.blueAccent,
                    textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton.icon(
                  icon: Icon(Icons.money),
                  onPressed: () => _finalizeTransaction("Gotówka"),
                  label: Text("Płatność gotówką"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                    backgroundColor: Colors.green,
                    textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
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
