import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:motora_app/components/generic_modal.dart';
import 'package:motora_app/constants/app_colors.dart';
import 'package:motora_app/models/restaurant_model.dart';
import 'package:motora_app/services/firestore_service.dart';

enum RestaurantFormMode { create, information, payment }

class RestaurantForm extends StatefulWidget {
  final RestaurantModel? restaurant;
  final RestaurantFormMode mode;

  const RestaurantForm({
    super.key,
    this.restaurant,
    this.mode = RestaurantFormMode.create,
  });

  @override
  State<RestaurantForm> createState() => _RestaurantFormState();
}

class _RestaurantFormState extends State<RestaurantForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _taxaFixaController = TextEditingController();
  final _taxaVariavelController = TextEditingController();
  final _quilometragemMinimaController = TextEditingController();

  bool _usaTaxaFixa = true;
  bool _usaTaxaVariavel = false;
  bool _isSaving = false;

  Color get _fieldLabelColor => AppColors.corTexto.withValues(alpha: 0.62);

  final TextInputFormatter _currencyInputFormatter =
      TextInputFormatter.withFunction((oldValue, newValue) {
        final regex = RegExp(r'^\d{0,6}([.,]\d{0,2})?$');
        return regex.hasMatch(newValue.text) ? newValue : oldValue;
      });

  final TextInputFormatter _kmInputFormatter = TextInputFormatter.withFunction((
    oldValue,
    newValue,
  ) {
    final regex = RegExp(r'^\d{0,5}([.,]\d{0,2})?$');
    return regex.hasMatch(newValue.text) ? newValue : oldValue;
  });

  bool get _showName =>
      widget.mode == RestaurantFormMode.create ||
      widget.mode == RestaurantFormMode.information;

  bool get _showPayment =>
      widget.mode == RestaurantFormMode.create ||
      widget.mode == RestaurantFormMode.payment;

  bool get _isEditing => widget.restaurant != null;

  String get _modalTitle {
    switch (widget.mode) {
      case RestaurantFormMode.information:
        return 'Editar Restaurante';
      case RestaurantFormMode.payment:
        return 'Editar Pagamento';
      case RestaurantFormMode.create:
        return 'Cadastrar Restaurante';
    }
  }

  String get _successMessage {
    switch (widget.mode) {
      case RestaurantFormMode.information:
        return 'Restaurante atualizado com sucesso!';
      case RestaurantFormMode.payment:
        return 'Perfil de pagamento atualizado com sucesso!';
      case RestaurantFormMode.create:
        return 'Restaurante cadastrado com sucesso!';
    }
  }

  @override
  void initState() {
    super.initState();

    final restaurant = widget.restaurant;
    if (restaurant == null) return;

    final perfil = restaurant.perfilPagamento;
    _nomeController.text = restaurant.nome;
    _usaTaxaFixa = perfil.usaTaxaFixa;
    _usaTaxaVariavel = perfil.usaTaxaVariavel;
    _taxaFixaController.text = _initialDecimal(perfil.taxaFixa);
    _taxaVariavelController.text = _initialDecimal(perfil.taxaVariavelPorKm);
    _quilometragemMinimaController.text =
        perfil.quilometragemMinimaTaxaVariavel == null
        ? ''
        : _initialDecimal(perfil.quilometragemMinimaTaxaVariavel!);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _taxaFixaController.dispose();
    _taxaVariavelController.dispose();
    _quilometragemMinimaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GenericModal(
      title: _modalTitle,
      content: Form(key: _formKey, child: _buildContent()),
      confirmButtonText: _isSaving
          ? 'Salvando...'
          : _isEditing
          ? 'Salvar'
          : 'Cadastrar',
      confirmButtonIcon: _isSaving
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.corTexto,
              ),
            )
          : const Icon(Icons.check_circle_outline, color: AppColors.corIcone),
      confirmButtonAction: _isSaving ? null : _saveRestaurant,
      confirmButtonColor: AppColors.corPrincipal,
      padding: const EdgeInsets.all(20),
      contentSpacing: 8,
      actionsSpacing: 26,
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_showName) ...[
          const Text(
            'Restaurante',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nomeController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Digite o nome do restaurante',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Informe o nome do restaurante';
              }
              return null;
            },
          ),
        ],
        if (_showName && _showPayment) const SizedBox(height: 22),
        if (_showPayment) _buildPaymentSection(),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Perfil de pagamento',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          value: _usaTaxaFixa,
          onChanged: (value) => setState(() => _usaTaxaFixa = value ?? false),
          title: 'Taxa fixa por entrega',
          controller: _taxaFixaController,
          labelText: 'Valor fixo',
          hintText: '2,00',
          prefixText: 'R\$ ',
          formatter: _currencyInputFormatter,
          enabled: _usaTaxaFixa,
          validator: (value) => _usaTaxaFixa
              ? _validatePositiveDecimal(value, 'o valor fixo')
              : null,
          helperText:
              'Eu recebo ${_moneyPreview(_taxaFixaController)} fixo por entrega que realizo.',
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          value: _usaTaxaVariavel,
          onChanged: (value) =>
              setState(() => _usaTaxaVariavel = value ?? false),
          title: 'Taxa variavel por km',
          controller: _taxaVariavelController,
          labelText: 'Valor por km',
          hintText: '1,50',
          prefixText: 'R\$ ',
          suffixText: '/km',
          formatter: _currencyInputFormatter,
          enabled: _usaTaxaVariavel,
          validator: (value) => _usaTaxaVariavel
              ? _validatePositiveDecimal(value, 'o valor por km')
              : null,
          helperText:
              'Eu recebo ${_moneyPreview(_taxaVariavelController)} a cada km que ando por entrega.',
        ),
        if (_usaTaxaFixa && _usaTaxaVariavel) ...[
          const SizedBox(height: 12),
          _buildCombinedRule(),
        ],
      ],
    );
  }

  Widget _buildPaymentOption({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String title,
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required String prefixText,
    required TextInputFormatter formatter,
    required bool enabled,
    required String? Function(String?) validator,
    required String helperText,
    String? suffixText,
  }) {
    final borderColor = value
        ? AppColors.corBordaFocadaInputs
        : AppColors.corBordaInputs;
    final textColor = value
        ? AppColors.corTexto
        : AppColors.corTexto.withValues(alpha: 0.55);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
      decoration: BoxDecoration(
        color: AppColors.corInputs,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Checkbox(
                value: value,
                activeColor: AppColors.corPrincipal,
                checkColor: AppColors.corTexto,
                onChanged: onChanged,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [formatter],
            onChanged: (_) => setState(() {}),
            validator: validator,
            decoration: InputDecoration(
              labelText: labelText,
              labelStyle: TextStyle(color: _fieldLabelColor),
              floatingLabelStyle: TextStyle(color: _fieldLabelColor),
              hintText: hintText,
              prefixText: prefixText,
              suffixText: suffixText,
              fillColor: enabled
                  ? AppColors.corInputs
                  : AppColors.corBordaInputs.withValues(alpha: 0.35),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            helperText,
            style: TextStyle(color: textColor, fontSize: 12, height: 1.25),
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedRule() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.corPrincipal.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.corBordaFocadaInputs),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Taxa mínima por entrega',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _quilometragemMinimaController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [_kmInputFormatter],
            onChanged: (_) => setState(() {}),
            validator: (value) =>
                _validatePositiveDecimal(value, 'a quilometragem minima'),
            decoration: InputDecoration(
              labelText: 'Quilometragem mínima',
              labelStyle: TextStyle(color: _fieldLabelColor),
              floatingLabelStyle: TextStyle(color: _fieldLabelColor),
              hintText: '3',
              suffixText: 'km',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Eu recebo ${_moneyPreview(_taxaFixaController)} para pedidos '
            'ate ${_kmPreview(_quilometragemMinimaController)} km; acima '
            'disso passo a receber ${_moneyPreview(_taxaVariavelController)} '
            'por km.',
            style: TextStyle(
              color: AppColors.corTexto.withValues(alpha: 0.75),
              fontSize: 12,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveRestaurant() async {
    if (!_formKey.currentState!.validate()) return;

    if (_showPayment && !_usaTaxaFixa && !_usaTaxaVariavel) {
      _showMessage(
        'Selecione pelo menos uma forma de pagamento.',
        AppColors.corErro,
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _showMessage('Usuario nao encontrado.', AppColors.corErro);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final service = FirestoreService();

      switch (widget.mode) {
        case RestaurantFormMode.create:
          final restaurant = RestaurantModel(
            nome: _nomeController.text.trim(),
            perfilPagamento: _buildPaymentProfile(),
            userId: userId,
          );
          await service.salvarRestaurante(restaurant);
          break;
        case RestaurantFormMode.information:
          final restaurant = widget.restaurant;
          if (restaurant == null || restaurant.id == null) {
            throw Exception('Restaurante nao encontrado');
          }
          await service.atualizarRestaurante(
            restaurant.copyWith(nome: _nomeController.text.trim()),
          );
          break;
        case RestaurantFormMode.payment:
          final restaurant = widget.restaurant;
          if (restaurant == null || restaurant.id == null) {
            throw Exception('Restaurante nao encontrado');
          }
          await service.atualizarPerfilPagamentoRestaurante(
            restaurant.id!,
            _buildPaymentProfile(),
          );
          break;
      }

      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(_successMessage),
          backgroundColor: AppColors.corSucesso,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Erro ao salvar restaurante. Verifique os campos.',
        AppColors.corErro,
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  PaymentProfile _buildPaymentProfile() {
    return PaymentProfile(
      usaTaxaFixa: _usaTaxaFixa,
      usaTaxaVariavel: _usaTaxaVariavel,
      taxaFixa: _usaTaxaFixa ? _parseDecimal(_taxaFixaController.text)! : 0,
      taxaVariavelPorKm: _usaTaxaVariavel
          ? _parseDecimal(_taxaVariavelController.text)!
          : 0,
      quilometragemMinimaTaxaVariavel: _usaTaxaFixa && _usaTaxaVariavel
          ? _parseDecimal(_quilometragemMinimaController.text)
          : null,
    );
  }

  String? _validatePositiveDecimal(String? value, String fieldName) {
    final parsedValue = _parseDecimal(value);
    if (parsedValue == null) {
      return 'Informe $fieldName';
    }
    if (parsedValue <= 0) {
      return 'Informe um valor maior que zero';
    }
    return null;
  }

  double? _parseDecimal(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }

  String _moneyPreview(TextEditingController controller) {
    final value = _parseDecimal(controller.text) ?? 0;
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _kmPreview(TextEditingController controller) {
    final value = _parseDecimal(controller.text) ?? 0;
    final precision = value.truncateToDouble() == value ? 0 : 2;
    return value.toStringAsFixed(precision).replaceAll('.', ',');
  }

  String _initialDecimal(double value) {
    if (value <= 0) return '';
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }
}
