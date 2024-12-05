import 'package:aplikacjasklepikuap/screens/koszyk_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> _fetchIlosc() async {
    try {
      final snapshot = await _firestore.collection('gadzety').get();
      for (var doc in snapshot.docs) {
        iloscZFirebase[doc.id] = doc.data()?['Ilość'] ?? 0;
        iloscDoZakupu[doc.id] = 0; // Domyślnie ilość do zakupu wynosi 0
        rabatUzyty[doc.id] = false; // Domyślnie rabat nie jest użyty
      }
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

  @override
  void initState() {
    super.initState();
    _fetchIlosc();
  }

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = 4;

    // Oblicz sumę przedmiotów w koszyku
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
                showDialog(
                  context: context,
                  builder: (context) => KoszykWidget(
                    iloscDoZakupu: iloscDoZakupu,
                    gadzety: gadzety,
                    rabatUzyty: rabatUzyty, // Przekazanie rabatów
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 0.8,
          ),
          itemCount: gadzety.length,
          itemBuilder: (context, index) {
            try {
              Gadzet gadzet = gadzety[index];

              // Obsługa brakujących danych
              String nazwa = gadzet.nazwa ?? "Nieznany gadżet";
              String obrazek = gadzet.obrazek ?? "assets/placeholder.png";
              double cena = gadzet.cena ?? 0.0;
              int iloscWMagazynie = iloscZFirebase[gadzet.nazwa] ?? 0;
              int iloscZakupu = iloscDoZakupu[gadzet.nazwa] ?? 0;

              // Cena całkowita z zaokrągloną zniżką
              double rabat = (rabatUzyty[gadzet.nazwa]! && iloscZakupu > 0)
                  ? (cena * 0.1).floorToDouble()
                  : 0.0;
              double cenaCalkowita = (iloscZakupu * cena) - rabat;

              return Stack(
                children: [
                  Card(
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
                                obrazek,
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
                            nazwa,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Cena: ${cena.toStringAsFixed(2)} zł",
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
                                    color: rabatUzyty[gadzet.nazwa]!
                                        ? Colors.grey
                                        : Colors.green[700]),
                                onPressed: () {
                                  if (!rabatUzyty[gadzet.nazwa]! &&
                                      iloscZakupu > 0) {
                                    setState(() {
                                      rabatUzyty[gadzet.nazwa] = true;
                                    });
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
                  ),
                ],
              );
            } catch (e) {
              print("Błąd z gadżetem na indeksie $index: $e");
              return Card(
                color: Colors.red,
                child: Center(
                  child: Text(
                    "Błąd przy wyświetlaniu produktu",
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
          },
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ElevatedButton(
            onPressed: () {
              // Przejście do płatności
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_forward, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  "Dalej",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            )),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
