import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aplikacjasklepikuap/screens/koszyk_screen.dart';
import '../models/gadzet.dart';

class GadzetSelectionScreen extends StatefulWidget {
  @override
  _GadzetSelectionScreenState createState() => _GadzetSelectionScreenState();
}

class _GadzetSelectionScreenState extends State<GadzetSelectionScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, int> iloscZFirebase = {};
  Map<String, int> iloscDoZakupu = {};
  Map<String, bool> rabatUzyty = {};
  List<Gadzet> gadzety = [];

  Future<void> _fetchIlosc() async {
    try {
      final snapshot = await _firestore.collection('gadzety').get();

      if (snapshot.docs.isEmpty) {
        print("Firestore: Brak danych w kolekcji 'gadzety'");
      } else {
        print("Firestore: Znaleziono ${snapshot.docs.length} dokumentów.");
      }

      gadzety = snapshot.docs.map((doc) {
        final data = doc.data();
        final nazwa = data['Nazwa'] ?? 'Nieznany';
        final cena =
            (data['Cena'] is num) ? (data['Cena'] as num).toDouble() : 0.0;
        final ilosc = data['Ilość'] ?? 0;

        iloscZFirebase[nazwa] = ilosc;
        iloscDoZakupu[nazwa] = 0;
        rabatUzyty[nazwa] = false;

        return Gadzet(
          nazwa: nazwa,
          cena: cena,
          obrazek: 'assets/gadzety/$nazwa.png',
        );
      }).toList();

      setState(() {});
    } catch (e) {
      print("Błąd podczas pobierania danych z Firestore: $e");
    }
  }

  Future<void> _updateIlosc(String nazwa, int newIlosc) async {
    try {
      await _firestore
          .collection('gadzety')
          .doc(nazwa)
          .update({'Ilość': newIlosc});
      iloscZFirebase[nazwa] = newIlosc;
      setState(() {});
    } catch (e) {
      print("Błąd podczas aktualizacji ilości w Firestore: $e");
    }
  }

  double _obliczCeneCalkowita(String nazwa) {
    final ilosc = iloscDoZakupu[nazwa] ?? 0;
    final cena = gadzety.firstWhere((g) => g.nazwa == nazwa).cena;
    final rabat = rabatUzyty[nazwa] ?? false;

    if (ilosc == 0) return 0.0;

    final rabatKwota = rabat ? (cena * 0.1).floorToDouble() : 0.0;
    return (ilosc * cena) - rabatKwota;
  }

  void _updateKoszyk() {
    setState(() {}); // Synchronizacja stanu
  }

  @override
  void initState() {
    super.initState();
    _fetchIlosc();
  }

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = 4;

    int liczbaPrzedmiotowWKoszyku =
        iloscDoZakupu.values.fold(0, (sum, ilosc) => sum + ilosc);

    return Scaffold(
      appBar: AppBar(
        title: Text("Wybierz gadżety"),
        backgroundColor: Colors.deepPurple,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                _updateKoszyk();
                showDialog(
                  context: context,
                  builder: (context) => KoszykWidget(
                    iloscDoZakupu: iloscDoZakupu,
                    gadzety: gadzety,
                    rabatUzyty: rabatUzyty,
                  ),
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.shopping_cart, size: 28),
                  if (liczbaPrzedmiotowWKoszyku > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          liczbaPrzedmiotowWKoszyku.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: gadzety.isEmpty
          ? Center(
              child: Text(
                "Brak gadżetów do wyświetlenia.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 0.96,
                ),
                itemCount: gadzety.length,
                itemBuilder: (context, index) {
                  final gadzet = gadzety[index];
                  final iloscWMagazynie = iloscZFirebase[gadzet.nazwa] ?? 0;
                  final iloscZakupu = iloscDoZakupu[gadzet.nazwa] ?? 0;
                  final rabat = rabatUzyty[gadzet.nazwa]!;

                  final cenaCalkowita = _obliczCeneCalkowita(gadzet.nazwa);

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.deepPurple[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                gadzet.obrazek,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/placeholder.png',
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            gadzet.nazwa,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Cena: ${gadzet.cena.toStringAsFixed(2)} zł",
                            style:
                                TextStyle(fontSize: 14, color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Ilość w magazynie: $iloscWMagazynie",
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Ilość do zakupu: $iloscZakupu",
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Cena całkowita: ${cenaCalkowita.toStringAsFixed(2)} zł",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: Icon(Icons.discount,
                                    color: rabat
                                        ? Colors.grey
                                        : Colors.green[700]),
                                onPressed: () {
                                  if (!rabat && iloscZakupu > 0) {
                                    setState(() {
                                      rabatUzyty[gadzet.nazwa] = true;
                                      print(
                                          "Rabat zastosowany dla: ${gadzet.nazwa}");
                                    });
                                  } else {
                                    print(
                                        "Nie można zastosować rabatu dla: ${gadzet.nazwa}");
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.add_circle,
                                    color: Colors.deepPurple),
                                onPressed: () {
                                  if (iloscWMagazynie > 0) {
                                    setState(() {
                                      iloscDoZakupu[gadzet.nazwa] =
                                          iloscZakupu + 1;
                                      _updateIlosc(
                                          gadzet.nazwa, iloscWMagazynie - 1);
                                    });
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.remove_circle,
                                    color: Colors.redAccent),
                                onPressed: () {
                                  if (iloscZakupu > 0) {
                                    setState(() {
                                      iloscDoZakupu[gadzet.nazwa] =
                                          iloscZakupu - 1;
                                      _updateIlosc(
                                          gadzet.nazwa, iloscWMagazynie + 1);
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
