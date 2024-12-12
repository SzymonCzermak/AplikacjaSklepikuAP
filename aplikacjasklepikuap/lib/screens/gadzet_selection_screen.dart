import 'package:aplikacjasklepikuap/screens/koszyk_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  String getImagePath(String nazwa) {
    // Generowanie poprawnej ścieżki do obrazków
    return 'assets/gadzety/$nazwa.png';
  }

  @override
  void initState() {
    super.initState();
    _fetchIlosc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wybierz gadżety"),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _firestore.collection('gadzety').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "Brak danych do wyświetlenia",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            );
          }

          final gadzety = snapshot.data!.docs;

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // Można dostosować ilość kolumn
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 0.8,
            ),
            itemCount: gadzety.length,
            itemBuilder: (context, index) {
              try {
                final itemData = gadzety[index].data() as Map<String, dynamic>?;

                if (itemData == null) {
                  throw Exception("Brak danych dla indeksu $index");
                }

                final nazwa = itemData['Nazwa'] ?? "Nieznany gadżet";
                final obrazek = getImagePath(nazwa);
                final cena = itemData['Cena'] ?? 0.0;
                final iloscWMagazynie = iloscZFirebase[nazwa] ?? 0;
                final iloscZakupu = iloscDoZakupu[nazwa] ?? 0;

                // Cena całkowita z zaokrągloną zniżką
                final rabat = (rabatUzyty[nazwa]! && iloscZakupu > 0)
                    ? (cena * 0.1).floorToDouble()
                    : 0.0;
                final cenaCalkowita = (iloscZakupu * cena) - rabat;

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
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black87),
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
                                      color: rabatUzyty[nazwa]!
                                          ? Colors.grey
                                          : Colors.green[700]),
                                  onPressed: () {
                                    if (!rabatUzyty[nazwa]! &&
                                        iloscZakupu > 0) {
                                      setState(() {
                                        rabatUzyty[nazwa] = true;
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
                                        iloscDoZakupu[nazwa] = iloscZakupu + 1;
                                        _updateIlosc(
                                            nazwa, iloscWMagazynie - 1);
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
                                        iloscDoZakupu[nazwa] = iloscZakupu - 1;
                                        _updateIlosc(
                                            nazwa, iloscWMagazynie + 1);
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
          );
        },
      ),
    );
  }
}
