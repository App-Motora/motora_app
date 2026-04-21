import 'package:flutter/material.dart';
import 'package:motora_app/home_page.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: HomePage()
      ),
    );
  }
}
