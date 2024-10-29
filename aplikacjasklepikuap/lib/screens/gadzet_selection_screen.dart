import 'package:flutter/material.dart';
import '../models/gadzet.dart';
import 'payment_screen.dart';

class GadzetSelectionScreen extends StatefulWidget {
  @override
  _GadzetSelectionScreenState createState() => _GadzetSelectionScreenState();
}

class _GadzetSelectionScreenState extends State<GadzetSelectionScreen> {
  List<Gadzet> koszyk = [];
  Map<String, int> licznikGadzetow = {}; // Służy do zliczania kliknięć każdego gadżetu

  void toggleRabatu(Gadzet gadzet) {
  setState(() {
    gadzet.licznikZnizki = gadzet.licznikZnizki == 0 ? 1 : 0;
    print("Rabat dla ${gadzet.nazwa}: ${gadzet.licznikZnizki}");
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

  @override
  Widget build(BuildContext context) {
    // Oblicz liczbę kolumn w zależności od szerokości ekranu
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 600 ? 4 : (screenWidth > 400 ? 3 : 2); // Dynamiczna liczba kolumn

    return Scaffold(
      appBar: AppBar(title: Text("Wybierz gadżety")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 0.7,
          ),
          itemCount: gadzety.length,
          itemBuilder: (context, index) {
            Gadzet gadzet = gadzety[index];
            return Stack(
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Image.asset(
                            gadzet.obrazek,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          gadzet.nazwa,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Cena: ${gadzet.cena.toStringAsFixed(2)} zł",
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Dodano: ${licznikGadzetow[gadzet.nazwa] ?? 0} szt.",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: Icon(Icons.discount, color: Colors.green),
                              onPressed: () => toggleRabatu(gadzet),
                            ),
                            IconButton(
                              icon: Icon(Icons.add, color: Colors.blue),
                              onPressed: () => dodajDoKoszyka(gadzet),
                            ),
                            if ((licznikGadzetow[gadzet.nazwa] ?? 0) > 0)
                              IconButton(
                                icon: Icon(Icons.remove, color: Colors.red),
                                onPressed: () => usunZKoszyka(gadzet),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Wskaźnik rabatu
                if (gadzet.licznikZnizki > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentScreen(koszyk: koszyk),
            ),
          );
        },
        child: Icon(Icons.arrow_forward),
      ),
    );
  }
}
