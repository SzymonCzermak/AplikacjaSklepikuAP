import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gadzet.dart';
import 'payment_screen.dart';

class GadzetSelectionScreen extends StatefulWidget {
  @override
  _GadzetSelectionScreenState createState() => _GadzetSelectionScreenState();
}

class _GadzetSelectionScreenState extends State<GadzetSelectionScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Gadzet> koszyk = [];
  Map<String, int> licznikGadzetow = {}; // Liczba dodanych sztuk każdego gadżetu

  void toggleRabatu(Gadzet gadzet) {
    setState(() {
      gadzet.licznikZnizki = gadzet.licznikZnizki == 0 ? 1 : 0;
    });
  }

  void dodajDoKoszyka(Gadzet gadzet) {
    setState(() {
      koszyk.add(gadzet);
      licznikGadzetow[gadzet.nazwa] = (licznikGadzetow[gadzet.nazwa] ?? 0) + 1;
    });
  }

  void usunZKoszyka(Gadzet gadzet) {
    if (licznikGadzetow[gadzet.nazwa] != null && licznikGadzetow[gadzet.nazwa]! > 0) {
      setState(() {
        koszyk.remove(gadzet);
        licznikGadzetow[gadzet.nazwa] = licznikGadzetow[gadzet.nazwa]! - 1;
      });
    }
  }

  Future<int> _fetchIlosc(String nazwa) async {
    final doc = await _firestore.collection('gadzety').doc(nazwa).get();
    return doc['Ilość'] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = 4; // Liczba kolumn w siatce

    return Scaffold(
      appBar: AppBar(
        title: Text("Wybierz gadżety"),
        backgroundColor: Colors.deepPurple,
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
            Gadzet gadzet = gadzety[index];
            return FutureBuilder<int>(
              future: _fetchIlosc(gadzet.nazwa),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final ilosc = snapshot.data ?? 0;
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
                                  gadzet.obrazek,
                                  fit: BoxFit.cover,
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
                              "Cena: ${gadzet.getCenaZRabatem(licznikGadzetow[gadzet.nazwa] ?? 0).toStringAsFixed(2)} zł",
                              style: TextStyle(fontSize: 14, color: Colors.black87),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Dodano: ${licznikGadzetow[gadzet.nazwa] ?? 0} szt.",
                              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.discount, color: Colors.green[700]),
                                  onPressed: () => toggleRabatu(gadzet),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add_circle, color: Colors.deepPurple),
                                  onPressed: () => dodajDoKoszyka(gadzet),
                                ),
                                if ((licznikGadzetow[gadzet.nazwa] ?? 0) > 0)
                                  IconButton(
                                    icon: Icon(Icons.remove_circle, color: Colors.redAccent),
                                    onPressed: () => usunZKoszyka(gadzet),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (gadzet.licznikZnizki > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Rabat!",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentScreen(koszyk: koszyk),
              ),
            );
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
          ),  
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
