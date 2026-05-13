import 'package:cloud_firestore/cloud_firestore.dart';

class Entrega {
  final String? id;
  final String restaurante;
  final double valor;
  final double quilometragem;
  final DateTime data;
  final String userId;

  Entrega({
    this.id,
    required this.restaurante,
    required this.valor,
    required this.quilometragem,
    required this.data,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'restaurante': restaurante,
      'valor': valor,
      'quilometragem': quilometragem,
      'data': Timestamp.fromDate(data), 
      'userId': userId,
    };
  }
}