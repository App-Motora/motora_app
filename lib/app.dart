import 'package:flutter/material.dart';
import 'package:motora_app/deliveries_history_page.dart';
import 'package:motora_app/home_page.dart';
import 'package:motora_app/login_page.dart';
import 'package:motora_app/registro_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        inputDecorationTheme: _buildInputDecorationTheme(),
        dropdownMenuTheme: DropdownMenuThemeData(
          inputDecorationTheme: _buildInputDecorationTheme()
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.orange,
          selectionHandleColor: Color(0xFF4FA8FF),
          selectionColor: Colors.orange.withValues(alpha: 0.3),
        ),
        disabledColor: Colors.grey.shade300,
      ),

      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/registro': (context) => const RegistroPage(),
        '/home': (context) => const HomePage(),
        '/deliveries_history': (context) => const DeliveriesHistoryPage(),
      },
    );
  }

  Widget _buildInputDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFFF3D080), // Cor amarela usada nos formulários
          width: 1.5,
        ),
      ),
      hintStyle: const TextStyle(color: Colors.black38),
    );
  }
}