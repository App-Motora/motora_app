import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:motora_app/firebase_options.dart'; 
import 'package:motora_app/app.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}