import 'package:flutter/material.dart';
import 'gadzet_selection_screen.dart';
import 'summary_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tło strony głównej
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Sklepik", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Nagłówek
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                'assets/gadzety/LogoAPE.png', // Ścieżka do obrazka w katalogu assets
                height: 350,
                fit: BoxFit.cover,
              ),
            ),
            ),
            SizedBox(height: 30),
            // Przyciski z większym stylem
            ElevatedButton.icon(
              icon: Icon(Icons.shopping_cart, size: 28, color: Colors.white),
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
                foregroundColor: Colors.white, backgroundColor: Colors.teal, padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.assessment, size: 28, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SummaryPage()),
                );
              },
              label: Text(
                "Podsumowanie sprzedaży",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.orangeAccent, padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            SizedBox(height: 40),
            // Dodatkowe elementy dekoracyjne, np. obrazek lub logo sklepu
          ],
        ),
      ),
    );
  }
}