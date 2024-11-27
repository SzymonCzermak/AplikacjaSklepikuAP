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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Baza danych gadżetów"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Lista rozwijana na górze
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('gadzety').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text(
                    "Brak danych do wyświetlenia",
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  );
                }

                final gadzety = snapshot.data!.docs;

                return DropdownButton<String>(
                  isExpanded: true,
                  hint: Text(
                    "Wybierz przedmiot",
                    style: TextStyle(fontSize: 18),
                  ),
                  value: _selectedItem,
                  items: gadzety.map((doc) {
                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(
                        doc['Nazwa'],
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedItem = value;
                      _currentQuantity =
                          gadzety.firstWhere((doc) => doc.id == value)['Ilość'];
                      _quantityController.text = _currentQuantity.toString();
                    });
                  },
                  style: TextStyle(color: Colors.black, fontSize: 18),
                  dropdownColor: Colors.white,
                );
              },
            ),
            if (_selectedItem != null && _currentQuantity != null)
              Expanded(
                child: Center(
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
                      mainAxisSize: MainAxisSize.min,
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
                        Text(
                          "Aktualna ilość:",
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[700]),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Przycisk -1
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
                            // Pole do wpisywania ilości
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
                                    vertical: 10,
                                    horizontal: 8,
                                  ),
                                ),
                                onSubmitted: (value) {
                                  final newQuantity = int.tryParse(value);
                                  if (newQuantity != null && newQuantity >= 0) {
                                    _updateQuantity(newQuantity);
                                  } else {
                                    _quantityController.text =
                                        _currentQuantity.toString();
                                  }
                                },
                              ),
                            ),
                            SizedBox(width: 20),
                            // Przycisk +1
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
        ),
      ),
    );
  }
}
