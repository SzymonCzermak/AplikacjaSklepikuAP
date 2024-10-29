import 'package:flutter/material.dart';
import 'screens/home_page.dart';

void main() {
  runApp(SklepikApp());
}

class SklepikApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}
