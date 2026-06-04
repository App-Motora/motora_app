import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:motora_app/categories_list_page.dart';
import 'package:motora_app/constants/app_colors.dart';
import 'package:motora_app/deliveries_history_page.dart';
import 'package:motora_app/expenses_history_page.dart';
import 'package:motora_app/home_page.dart';
import 'package:motora_app/login_page.dart';
import 'package:motora_app/perfil.dart';
import 'package:motora_app/registro_page.dart';
import 'package:motora_app/restaurants_list_page.dart';
import 'package:motora_app/reports_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        inputDecorationTheme: _buildInputDecorationTheme(),
        dropdownMenuTheme: DropdownMenuThemeData(
          inputDecorationTheme: _buildInputDecorationTheme(),
          menuStyle: MenuStyle(
            backgroundColor: const WidgetStatePropertyAll(AppColors.corInputs),
            surfaceTintColor: const WidgetStatePropertyAll(AppColors.corInputs),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          textStyle: const TextStyle(color: AppColors.corTexto, fontSize: 16),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.corCursorSelecao,
          selectionHandleColor: AppColors.corSecundaria,
          selectionColor: AppColors.corCursorSelecao.withValues(alpha: 0.3),
        ),
        disabledColor: AppColors.corBordaInputs,
      ),

      initialRoute: '/',
      routes: {
        '/': (context) => const AuthCheck(),
        '/login': (context) => const LoginPage(),
        '/registro': (context) => const RegistroPage(),
        '/home': (context) => const HomePage(),
        '/perfil': (context) => const PerfilPage(),
        '/expenses_history': (context) => const ExpensesHistoryPage(),
        '/deliveries_history': (context) => const DeliveriesHistoryPage(),
        '/restaurants': (context) => const RestaurantsListPage(),
        '/reports': (context) => const ReportsPage(),
        '/categories': (context) => const CategoriesListPage(),
      },
    );
  }

  Widget _buildInputDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.corInputs,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.corBordaInputs),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.corBordaFocadaInputs,
          width: 1.5,
        ),
      ),
      hintStyle: TextStyle(color: AppColors.corHintInputs),
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.corSecundaria),
            ),
          );
        }
        if (snapshot.hasData) {
          return const HomePage();
        }
        return const LoginPage();
      },
    );
  }
}
