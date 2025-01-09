import 'package:flutter/material.dart';
import 'gadzet_selection_screen.dart';
import 'summary_page.dart';
import 'database_page.dart'; // Import nowej strony

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 44, 44, 44),
      appBar: AppBar(
        title: Text(
          "Aplikacja sprzedaży gadżetów",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 163, 84, 0),
        elevation: 4,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                'assets/gadzety/LogoAPE.png',
                height: 350,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
  icon: Icon(Icons.shopping_cart, size: 28, color: Colors.black),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GadzetSelectionScreen()),
    );
  },
  label: Text(
    "Rozpocznij zakupy",
    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  ),
  style: ElevatedButton.styleFrom(
    foregroundColor: Colors.black,
    backgroundColor: Colors.teal,
    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: Colors.black, width: 2), // Dodano ramkę
    ),
    elevation: 8, // Dodano cień
    shadowColor: Colors.black54, // Kolor cienia
  ),
),
SizedBox(height: 20),
ElevatedButton.icon(
  icon: Icon(Icons.assessment, size: 28, color: Colors.black),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TransactionsSummaryScreen()),
    );
  },
  label: Text(
    "Podsumowanie sprzedaży",
    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  ),
  style: ElevatedButton.styleFrom(
    foregroundColor: Colors.black,
    backgroundColor: Colors.orangeAccent,
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: Colors.black, width: 2), // Dodano ramkę
    ),
    elevation: 8, // Dodano cień
    shadowColor: Colors.black54, // Kolor cienia
  ),
),
SizedBox(height: 20),
ElevatedButton.icon(
  icon: Icon(Icons.storage, size: 28, color: Colors.black),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DatabasePage()),
    );
  },
  label: Text(
    "Baza danych",
    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  ),
  style: ElevatedButton.styleFrom(
    foregroundColor: Colors.black,
    backgroundColor: Colors.blueAccent,
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: Colors.black, width: 2), // Dodano ramkę
    ),
    elevation: 8, // Dodano cień
    shadowColor: Colors.black54, // Kolor cienia
  ),
),

          ],
        ),
      ),
    );
  }
}
