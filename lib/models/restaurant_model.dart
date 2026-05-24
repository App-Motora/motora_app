class PaymentProfile {
  final bool usaTaxaFixa;
  final bool usaTaxaVariavel;
  final double taxaFixa;
  final double taxaVariavelPorKm;
  final double? quilometragemMinimaTaxaVariavel;

  const PaymentProfile({
    required this.usaTaxaFixa,
    required this.usaTaxaVariavel,
    required this.taxaFixa,
    required this.taxaVariavelPorKm,
    this.quilometragemMinimaTaxaVariavel,
  });

  bool get usaPerfilCombinado => usaTaxaFixa && usaTaxaVariavel;

  Map<String, dynamic> toMap() {
    return {
      'usaTaxaFixa': usaTaxaFixa,
      'taxaFixa': usaTaxaFixa ? taxaFixa : 0,
      'usaTaxaVariavel': usaTaxaVariavel,
      'taxaVariavelPorKm': usaTaxaVariavel ? taxaVariavelPorKm : 0,
      'quilometragemMinimaTaxaVariavel': usaPerfilCombinado
          ? quilometragemMinimaTaxaVariavel
          : null,
      'tipo': _tipo,
    };
  }

  factory PaymentProfile.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const PaymentProfile(
        usaTaxaFixa: false,
        usaTaxaVariavel: false,
        taxaFixa: 0,
        taxaVariavelPorKm: 0,
      );
    }

    return PaymentProfile(
      usaTaxaFixa: map['usaTaxaFixa'] == true,
      usaTaxaVariavel: map['usaTaxaVariavel'] == true,
      taxaFixa: _toDouble(map['taxaFixa']),
      taxaVariavelPorKm: _toDouble(map['taxaVariavelPorKm']),
      quilometragemMinimaTaxaVariavel:
          map['quilometragemMinimaTaxaVariavel'] == null
          ? null
          : _toDouble(map['quilometragemMinimaTaxaVariavel']),
    );
  }

  String get resumo {
    if (usaPerfilCombinado) {
      final km = _formatDecimal(quilometragemMinimaTaxaVariavel ?? 0);
      return '${_formatCurrency(taxaFixa)} ate $km km; acima '
          '${_formatCurrency(taxaVariavelPorKm)}/km';
    }

    if (usaTaxaFixa) {
      return '${_formatCurrency(taxaFixa)} fixo por entrega';
    }

    if (usaTaxaVariavel) {
      return '${_formatCurrency(taxaVariavelPorKm)} por km rodado';
    }

    return 'Perfil de pagamento nao configurado';
  }

  String get _tipo {
    if (usaPerfilCombinado) return 'fixa_ate_km_variavel_acima';
    if (usaTaxaFixa) return 'fixa';
    if (usaTaxaVariavel) return 'variavel';
    return 'nao_configurado';
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.')) ?? 0;
    }
    return 0;
  }

  static String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  static String _formatDecimal(double value) {
    final text = value.toStringAsFixed(
      value.truncateToDouble() == value ? 0 : 2,
    );
    return text.replaceAll('.', ',');
  }
}

class RestaurantModel {
  final String? id;
  final String nome;
  final PaymentProfile perfilPagamento;
  final String userId;

  const RestaurantModel({
    this.id,
    required this.nome,
    required this.perfilPagamento,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'perfilPagamento': perfilPagamento.toMap(),
      'userId': userId,
    };
  }

  factory RestaurantModel.fromMap(String id, Map<String, dynamic> map) {
    final rawPaymentProfile = map['perfilPagamento'];

    return RestaurantModel(
      id: id,
      nome: map['nome']?.toString() ?? '',
      perfilPagamento: PaymentProfile.fromMap(
        rawPaymentProfile is Map
            ? Map<String, dynamic>.from(rawPaymentProfile)
            : null,
      ),
      userId: map['userId']?.toString() ?? '',
    );
  }

  RestaurantModel copyWith({
    String? id,
    String? nome,
    PaymentProfile? perfilPagamento,
    String? userId,
  }) {
    return RestaurantModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      perfilPagamento: perfilPagamento ?? this.perfilPagamento,
      userId: userId ?? this.userId,
    );
  }
}
