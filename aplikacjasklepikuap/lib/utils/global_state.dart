class GlobalState {
  // static double sumaSprzedazy = 0;
  // static double sumaRabaty = 0; // Całkowita wartość rabatów
  static int liczbaTransakcjiGotowka = 0;
  static int liczbaTransakcjiKarta = 0;
  static double sumaGotowka = 0; // Suma dla transakcji gotówką
  static double sumaKarta = 0; // Suma dla transakcji kartą
  static int liczbaTransakcjiParagon = 0; // Dodane pole
  static double sumaParagon = 0.0; // Suma dla transakcji kartą
  static Map<String, int> iloscGadzetow = {};
  static Map<String, int> sprzedaneGadzety =
      {}; // Przechowuje sprzedane gadżety
  static double sumaSprzedazy = 0.0; // Całkowita suma sprzedaży
  static double sumaRabaty = 0.0; // Łączna wartość rabatów
}
