import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/delivery_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  Future<void> salvarEntregaManual(Entrega entrega) async {
    try {
      await _db
          .collection('usuarios')
          .doc(_uid)
          .collection('entregas')
          .add(entrega.toMap());
    } catch (e) {
      throw Exception('Erro ao salvar entrega: $e');
    }
  }
}