class Categoria {
  final String? id;
  final String nome;
  final String userId;
  final int iconCode; 

  Categoria({
    this.id,
    required this.nome,
    required this.userId,
    this.iconCode = 0xe148, 
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'userId': userId,
      'iconCode': iconCode, 
    };
  }

  factory Categoria.fromMap(String id, Map<String, dynamic> map) {
    return Categoria(
      id: id,
      nome: map['nome'] ?? '',
      userId: map['userId'] ?? '',
      iconCode: map['iconCode'] ?? 0xe148, 
    );
  }
}