class Gadzet {
  String nazwa;
  double cena;
  bool zRabatem;
  String obrazek;
  int licznikZnizki = 0; // licznik zniżek dla jednorazowego rabatu

  Gadzet({required this.nazwa, required this.cena, this.zRabatem = false, required this.obrazek});

  // Funkcja oblicza cenę z rabatem, naliczając zniżkę tylko dla jednego egzemplarza
  double getCenaZRabatem(int ilosc) {
  if (licznikZnizki > 0 && ilosc > 0) {
    // Cena z rabatem dla jednego egzemplarza
    double cenaZRabatem = (cena * 0.9).floorToDouble();
    // Łączna cena: rabat na jeden egzemplarz + pełna cena dla pozostałych
    return cenaZRabatem + (ilosc - 1) * cena;
  }
  // Jeśli rabat nie jest aktywny, zwracamy cenę bez rabatu
  return ilosc * cena;
}

}



// Lista gadżetów dostępnych w sklepie (przykładowe ścieżki obrazków)
List<Gadzet> gadzety = [
  Gadzet(nazwa: "Butelka Czarna", cena: 25.0, obrazek: "assets/gadzety/Butelka Czarna.png"),
  Gadzet(nazwa: "Butelka pomarańczowa", cena: 25.0, obrazek: "assets/gadzety/Butelka pomarańczowa.png"),
  Gadzet(nazwa: "Długopis", cena: 8.0, obrazek: "assets/gadzety/Długopis.png"),
  Gadzet(nazwa: "Herbata", cena: 5.0, obrazek: "assets/gadzety/Herbata.png"),
  Gadzet(nazwa: "Kawa", cena: 7.0, obrazek: "assets/gadzety/Kawa.png"),
  Gadzet(nazwa: "Magnes kopuły pionowy", cena: 10.0, obrazek: "assets/gadzety/Magnes kopuły pionowy.png"),
  Gadzet(nazwa: "Magnes kopuły poziomy", cena: 10.0, obrazek: "assets/gadzety/Magnes kopuły poziomy.png"),
  Gadzet(nazwa: "Magnes wejście", cena: 10.0, obrazek: "assets/gadzety/Magnes wejście.png"),
  Gadzet(nazwa: "Smycz", cena: 8.0, obrazek: "assets/gadzety/Smycz.png"),
  Gadzet(nazwa: "Zdjęcie", cena: 17.0, obrazek: "assets/gadzety/Zdjęcie.png"),
];

