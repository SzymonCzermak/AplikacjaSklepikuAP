import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabasePage extends StatefulWidget {
  @override
  _DatabasePageState createState() => _DatabasePageState();
}

class _DatabasePageState extends State<DatabasePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedItem; // Wybrany przedmiot
  int? _currentQuantity; // Ilość wybranego przedmiotu
  final TextEditingController _quantityController = TextEditingController();

  void _updateQuantity(int newQuantity) async {
    if (_selectedItem == null) return;

    await _firestore.collection('gadzety').doc(_selectedItem).update({
      'Ilość': newQuantity,
    });

    setState(() {
      _currentQuantity = newQuantity;
      _quantityController.text = newQuantity.toString();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Zaktualizowano ilość dla $_selectedItem"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String getImagePath(String itemName) {
    // Generujemy ścieżkę do pliku na podstawie nazwy
    return 'assets/gadzety/$itemName.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Baza danych gadżetów"),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('gadzety').snapshots(),
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

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: gadzety.map((item) {
                    final itemData = item.data() as Map<String, dynamic>;
                    final itemName = itemData['Nazwa'];
                    final itemImagePath = getImagePath(itemName);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedItem = item.id;
                          _currentQuantity = itemData['Ilość'];
                          _quantityController.text =
                              _currentQuantity.toString();
                        });
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 96, // Zwiększono o 20%
                            height: 96, // Zwiększono o 20%
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                itemImagePath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.image_not_supported,
                                    size: 40,
                                    color: Colors.grey,
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            itemName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 16),
              if (_selectedItem != null && _currentQuantity != null)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Wybrano: $_selectedItem",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            width: 250, // Zwiększono o 70%
                            height: 250, // Zwiększono o 70%
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                _selectedItem != null
                                    ? getImagePath((gadzety
                                            .firstWhere((doc) =>
                                                doc.id == _selectedItem)
                                            .data()
                                        as Map<String, dynamic>)['Nazwa'])
                                    : "assets/placeholder.png",
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.image_not_supported,
                                    size: 40,
                                    color: Colors.grey,
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Aktualna ilość: $_currentQuantity",
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[700]),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (_currentQuantity! > 0) {
                                    _updateQuantity(_currentQuantity! - 1);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 24),
                                  backgroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  "-1",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: 20),
                              Container(
                                width: 80,
                                child: TextField(
                                  controller: _quantityController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 18),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 8),
                                  ),
                                  onSubmitted: (value) {
                                    final newQuantity = int.tryParse(value);
                                    if (newQuantity != null &&
                                        newQuantity >= 0) {
                                      _updateQuantity(newQuantity);
                                    } else {
                                      _quantityController.text =
                                          _currentQuantity.toString();
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: () {
                                  _updateQuantity(_currentQuantity! + 1);
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 24),
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  "+1",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
