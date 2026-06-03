class Categoria {
  final String? id;
  final String nome;
  final String userId;

  Categoria({
    this.id,
    required this.nome,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'userId': userId,
    };
  }

  factory Categoria.fromMap(String id, Map<String, dynamic> map) {
    return Categoria(
      id: id,
      nome: map['nome'] ?? '',
      userId: map['userId'] ?? '',
    );
  }
}