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

  Future<void> atualizarEntrega(Entrega entrega) async {
    if (entrega.id == null) {
      throw Exception('Erro ao atualizar entrega: id não encontrado');
    }

    try {
      await _db
          .collection('usuarios')
          .doc(_uid)
          .collection('entregas')
          .doc(entrega.id)
          .update(entrega.toMap());
    } catch (e) {
      throw Exception('Erro ao atualizar entrega: $e');
    }
  }

  Future<void> excluirEntrega(String entregaId) async {
    try {
      await _db
          .collection('usuarios')
          .doc(_uid)
          .collection('entregas')
          .doc(entregaId)
          .delete();
    } catch (e) {
      throw Exception('Erro ao excluir entrega: $e');
    }
  }

  Stream<List<Entrega>> buscarEntregas() {
    return _db
        .collection('usuarios')
        .doc(_uid)
        .collection('entregas')
        .orderBy('data', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return Entrega(
              id: doc.id,
              restaurante: data['restaurante'],
              valor: data['valor'].toDouble(),
              quilometragem: data['quilometragem'].toDouble(),
              data: (data['data'] as Timestamp).toDate(),
              userId: data['userId'],
            );
          }).toList(),
        );
  }
}
