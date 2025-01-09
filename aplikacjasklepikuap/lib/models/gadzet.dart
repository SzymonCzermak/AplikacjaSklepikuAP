class Gadzet {
  String nazwa;
  double cena;
  double rabat;
  String obrazek;

  Gadzet({
    required this.nazwa,
    required this.cena,
    required this.rabat,
    required this.obrazek,
  });

  // Metoda do tworzenia obiektu Gadzet z danych Firestore
  factory Gadzet.fromFirestore(Map<String, dynamic> data) {
    return Gadzet(
      nazwa: data['Nazwa'] ?? 'Nieznany',
      cena: (data['Cena'] is num) ? (data['Cena'] as num).toDouble() : 0.0,
      rabat: (data['Rabat'] is num) ? (data['Rabat'] as num).toDouble() : 0.0,
      obrazek: 'assets/gadzety/${data['Nazwa']}.png',
    );
  }
}
