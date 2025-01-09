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
  double? _currentPrice; // Cena wybranego przedmiotu
  double? _currentDiscount; // Rabat wybranego przedmiotu

  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  /// Aktualizuje ilość w magazynie
  Future<void> _updateQuantity(int newQuantity) async {
    if (_selectedItem == null) return;

    try {
      await _firestore.collection('gadzety').doc(_selectedItem).update({
        'Ilość': newQuantity,
      });

      setState(() {
        _currentQuantity = newQuantity;
        _quantityController.text = newQuantity.toString();
      });

      _showSnackbar("Zaktualizowano ilość dla $_selectedItem");
    } catch (e) {
      _showSnackbar("Błąd aktualizacji ilości: $e", isError: true);
    }
  }

  /// Aktualizuje cenę gadżetu
  Future<void> _updatePrice(double newPrice) async {
    if (_selectedItem == null) return;

    try {
      await _firestore.collection('gadzety').doc(_selectedItem).update({
        'Cena': newPrice,
      });

      setState(() {
        _currentPrice = newPrice;
        _priceController.text = newPrice.toStringAsFixed(2);
      });

      _showSnackbar("Zaktualizowano cenę dla $_selectedItem");
    } catch (e) {
      _showSnackbar("Błąd aktualizacji ceny: $e", isError: true);
    }
  }

  /// Aktualizuje rabat gadżetu
  Future<void> _updateDiscount(double newDiscount) async {
    if (_selectedItem == null) return;

    try {
      await _firestore.collection('gadzety').doc(_selectedItem).update({
        'Rabat': newDiscount,
      });

      setState(() {
        _currentDiscount = newDiscount;
        _discountController.text = newDiscount.toStringAsFixed(2);
      });

      _showSnackbar("Zaktualizowano rabat dla $_selectedItem");
    } catch (e) {
      _showSnackbar("Błąd aktualizacji rabatu: $e", isError: true);
    }
  }

  /// Pokazuje komunikat Snackbar
  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String getImagePath(String itemName) {
    return 'assets/gadzety/$itemName.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Baza danych gadżetów"),
        backgroundColor: const Color.fromARGB(255, 163, 84, 0),
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
  child: Wrap(
    spacing: 16, // Odstęp między elementami w poziomie
    runSpacing: 16, // Odstęp między wierszami
    alignment: WrapAlignment.center, // Wyśrodkowanie elementów
    children: gadzety.map((item) {
      final itemData = item.data() as Map<String, dynamic>;
      final itemName = itemData['Nazwa'];
      final itemImagePath = getImagePath(itemName);

      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedItem = item.id;
            _currentQuantity = itemData['Ilość'];
            _currentPrice = (itemData['Cena'] as num).toDouble();
            _currentDiscount =
                (itemData['Rabat'] as num?)?.toDouble() ?? 0.0;
            _quantityController.text = _currentQuantity.toString();
            _priceController.text = _currentPrice!.toStringAsFixed(2);
            _discountController.text = _currentDiscount!.toStringAsFixed(2);
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 75, // Zmniejszono szerokość kontenera
              height: 75, // Zmniejszono wysokość kontenera
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
                fontSize: 10, // Zmniejszono rozmiar tekstu
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
              if (_selectedItem != null)
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildEditableField(
                                label: "Ilość",
                                controller: _quantityController,
                                onUpdate: (value) {
                                  final newQuantity = int.tryParse(value);
                                  if (newQuantity != null && newQuantity >= 0) {
                                    _updateQuantity(newQuantity);
                                  }
                                },
                              ),
                              _buildEditableField(
                                label: "Cena (zł)",
                                controller: _priceController,
                                onUpdate: (value) {
                                  final newPrice = double.tryParse(value);
                                  if (newPrice != null && newPrice >= 0) {
                                    _updatePrice(newPrice);
                                  }
                                },
                              ),
                              _buildEditableField(
                                label: "Rabat (zł)",
                                controller: _discountController,
                                onUpdate: (value) {
                                  final newDiscount = double.tryParse(value);
                                  if (newDiscount != null && newDiscount >= 0) {
                                    _updateDiscount(newDiscount);
                                  }
                                },
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

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required Function(String) onUpdate,
  }) {
    return Column(
      children: [
        Text(label),
        SizedBox(height: 10),
        Container(
          width: 100,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            ),
            onSubmitted: onUpdate,
          ),
        ),
      ],
    );
  }
}
