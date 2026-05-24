import 'package:cloud_firestore/cloud_firestore.dart';

class Turno {
  final String? id;
  final String restaurante;
  final DateTime iniciadoEm;
  final DateTime? encerradoEm;
  final String userId;

  const Turno({
    this.id,
    required this.restaurante,
    required this.iniciadoEm,
    this.encerradoEm,
    required this.userId,
  });

  bool get estaAtivo => encerradoEm == null;

  Map<String, dynamic> toMap() {
    return {
      'restaurante': restaurante,
      'iniciadoEm': Timestamp.fromDate(iniciadoEm),
      'encerradoEm': encerradoEm == null
          ? null
          : Timestamp.fromDate(encerradoEm!),
      'userId': userId,
    };
  }

  factory Turno.fromMap(String id, Map<String, dynamic> map) {
    final encerradoEm = map['encerradoEm'];

    return Turno(
      id: id,
      restaurante: map['restaurante'] ?? '',
      iniciadoEm: (map['iniciadoEm'] as Timestamp).toDate(),
      encerradoEm: encerradoEm is Timestamp ? encerradoEm.toDate() : null,
      userId: map['userId'] ?? '',
    );
  }
}
