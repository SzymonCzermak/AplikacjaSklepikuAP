import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core
import 'screens/home_page.dart'; // Strona główna aplikacji

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicjalizacja Firebase
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDZgvT6EiB2Newf-lZQoSDghm4tybYgsgU",
      authDomain: "alverniaplanetdatabase.firebaseapp.com",
      projectId: "alverniaplanetdatabase",
      storageBucket: "alverniaplanetdatabase.firebasestorage.app",
      messagingSenderId: "334697458755",
      appId: "1:334697458755:web:383919a1c85b223b76f8f6",
      measurementId: "G-3YQ20HX9FT",
    ),
  );

  runApp(SklepikApp());
}

class SklepikApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sklepik lokalny',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
