class GlobalState {
  // Łączne podsumowanie sprzedaży
  static double sumaSprzedazy = 0.0;

  // Gotówka
  static double sumaGotowka = 0.0;
  static double sumaRabatyGotowka = 0.0;
  static List<Map<String, dynamic>> gotowkaTransactions = [];

  // Karta
  static double sumaKarta = 0.0;
  static double sumaRabatyKarta = 0.0;
  static List<Map<String, dynamic>> kartaTransactions = [];

  // Podsumowanie ilości sprzedanych gadżetów
  static Map<String, int> iloscGadzetow = {};
}
