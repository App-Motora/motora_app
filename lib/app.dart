import 'package:flutter/material.dart';
import 'package:motora_app/home_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade600),
          )
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.orange,
          selectionHandleColor: Color(0xFF4FA8FF), 
          selectionColor: Colors.orange.withValues(alpha: 0.3),
        ),
        disabledColor: Colors.grey.shade300
      ),
      home: HomePage(),
    );
  }
}