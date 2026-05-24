import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/delivery_model.dart';
import '../models/expense_model.dart';

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

  Stream<List<Entrega>> buscarEntregasDoDia() {
    final now = DateTime.now();
    final inicioDoDia = DateTime(now.year, now.month, now.day);
    final inicioDoProximoDia = inicioDoDia.add(const Duration(days: 1));

    return _db
        .collection('usuarios')
        .doc(_uid)
        .collection('entregas')
        .where('data', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDoDia))
        .where('data', isLessThan: Timestamp.fromDate(inicioDoProximoDia))
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

  Future<void> salvarEntregaAutomatica(Entrega entrega) async {
    try {
      await _db
          .collection('usuarios')
          .doc(_uid)
          .collection('entregas')
          .add(entrega.toMap());
    } catch (e) {
      throw Exception('Erro ao salvar entrega automática: $e');
    }
  }

  Future<void> salvarDespesa(Despesa despesa) async {
    try {
      await _db
          .collection('usuarios')
          .doc(_uid)
          .collection('despesas')
          .add(despesa.toMap());
    } catch (e) {
      throw Exception('Erro ao salvar despesa: $e');
    }
  }

  Future<void> atualizarDespesa(Despesa despesa) async {
    if (despesa.id == null) {
      throw Exception('Erro ao atualizar despesa: id não encontrado');
    }
    try {
      await _db
          .collection('usuarios')
          .doc(_uid)
          .collection('despesas')
          .doc(despesa.id)
          .update(despesa.toMap());
    } catch (e) {
      throw Exception('Erro ao atualizar despesa: $e');
    }
  }

  Future<void> excluirDespesa(String despesaId) async {
    try {
      await _db
          .collection('usuarios')
          .doc(_uid)
          .collection('despesas')
          .doc(despesaId)
          .delete();
    } catch (e) {
      throw Exception('Erro ao excluir despesa: $e');
    }
  }

  Stream<List<Despesa>> buscarDespesas() {
    return _db
        .collection('usuarios')
        .doc(_uid)
        .collection('despesas')
        .orderBy('data', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            return Despesa.fromMap(doc.id, doc.data());
          }).toList(),
        );
  }

  Stream<List<Despesa>> buscarDespesasDoDia() {
    final now = DateTime.now();
    final inicioDoDia = DateTime(now.year, now.month, now.day);
    final inicioDoProximoDia = inicioDoDia.add(const Duration(days: 1));

    return _db
        .collection('usuarios')
        .doc(_uid)
        .collection('despesas')
        .where('data', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDoDia))
        .where('data', isLessThan: Timestamp.fromDate(inicioDoProximoDia))
        .orderBy('data', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            return Despesa.fromMap(doc.id, doc.data());
          }).toList(),
        );
  }
}
