import 'package:cloud_firestore/cloud_firestore.dart';

class Despesa {
  final String? id;
  final String categoria; 
  final String descricao;
  final double valor;
  final DateTime data;
  final String userId;

  Despesa({
    this.id,
    required this.categoria,
    required this.descricao,
    required this.valor,
    required this.data,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'categoria': categoria,
      'descricao': descricao,
      'valor': valor,
      'data': data,
      'userId': userId,
    };
  }

  factory Despesa.fromMap(String id, Map<String, dynamic> map) {
    return Despesa(
      id: id,
      categoria: map['categoria'] ?? 'Outros',
      descricao: map['descricao'] ?? '',
      valor: (map['valor'] ?? 0).toDouble(),
      data: (map['data'] as Timestamp).toDate(),
      userId: map['userId'] ?? '',
    );
  }
}