import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:motora_app/components/generic_modal.dart';
import 'package:motora_app/constants/app_colors.dart';
import 'package:motora_app/models/expense_model.dart';
import 'package:motora_app/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AutomaticExpenseForm extends StatefulWidget {
  final Despesa? despesaParaEditar;

  const AutomaticExpenseForm({super.key, this.despesaParaEditar});

  @override
  State<AutomaticExpenseForm> createState() => _AutomaticExpenseFormState();
}

class _AutomaticExpenseFormState extends State<AutomaticExpenseForm> {
  String? categoriaSelecionada = 'Combustivel';
  final List<String> categoriasDespesa = [
    'Combustivel',
    'Alimentacao',
    'Manutencao',
  ];

  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  bool _isSaving = false;
  final TextInputFormatter _valorInputFormatter =
      TextInputFormatter.withFunction((oldValue, newValue) {
        final RegExp regex = RegExp(r'^\d*([.,]\d{0,2})?$');
        return regex.hasMatch(newValue.text) ? newValue : oldValue;
      });

  @override
  void initState() {
    super.initState();
    if (widget.despesaParaEditar != null) {
      final d = widget.despesaParaEditar!;
      categoriaSelecionada = categoriasDespesa.contains(d.categoria)
          ? d.categoria
          : categoriasDespesa.first;
      _descricaoController.text = d.descricao;
      _valorController.text = d.valor.toStringAsFixed(2).replaceAll('.', ',');
      _dataController.text = DateFormat('dd/MM/yyyy').format(d.data);
    } else {
      _valorController.text = '';
      _dataController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    }
  }

  @override
  void dispose() {
    _valorController.dispose();
    _descricaoController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final DateTime now = DateTime.now();
    DateTime initialDate = widget.despesaParaEditar?.data ?? now;
    if (initialDate.isAfter(now)) {
      initialDate = now;
    }

    if (_dataController.text.isNotEmpty) {
      try {
        initialDate = DateFormat(
          'dd/MM/yyyy',
        ).parseStrict(_dataController.text);
      } catch (_) {}
    }

    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: now,
    );

    if (dataSelecionada == null) return;

    final String dia = dataSelecionada.day.toString().padLeft(2, '0');
    final String mes = dataSelecionada.month.toString().padLeft(2, '0');
    final String ano = dataSelecionada.year.toString();

    setState(() {
      _dataController.text = '$dia/$mes/$ano';
    });
  }

  Future<void> _salvarDespesa() async {
    final valorString = _valorController.text.replaceAll(',', '.').trim();
    final double? valorNum = double.tryParse(valorString);
    final descricaoText = _descricaoController.text.trim();

    if (valorNum == null ||
        valorNum <= 0 ||
        descricaoText.isEmpty ||
        categoriaSelecionada == null ||
        _dataController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe um valor, descrição e data válidos.'),
          backgroundColor: AppColors.corErro,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final dataFormatada = DateFormat(
        'dd/MM/yyyy',
      ).parseStrict(_dataController.text);

      final despesa = Despesa(
        id: widget.despesaParaEditar?.id,
        categoria: categoriaSelecionada!,
        descricao: descricaoText,
        valor: valorNum,
        data: dataFormatada,
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      );

      final firestoreService = FirestoreService();

      if (widget.despesaParaEditar == null) {
        await firestoreService.salvarDespesa(despesa);
      } else {
        await firestoreService.atualizarDespesa(despesa);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: AppColors.corErro,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GenericModal(
      title: widget.despesaParaEditar == null
          ? 'Cadastrar Despesa'
          : 'Editar Despesa',
      content: _buildContent(),
      confirmButtonText: _isSaving ? 'Salvando...' : 'Cadastrar',
      confirmButtonIcon: _isSaving
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: AppColors.corIcone,
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.check_circle_outline, color: AppColors.corIcone),
      confirmButtonAction: _isSaving ? null : _salvarDespesa,
      confirmButtonColor: AppColors.corPrincipal,
      padding: const EdgeInsets.all(20.0),
      actionsSpacing: 30,
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categoria da Despesa',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return DropdownMenu<String>(
              width: constraints.maxWidth,
              initialSelection: categoriaSelecionada,
              textStyle: const TextStyle(
                color: AppColors.corTexto,
                fontSize: 15,
              ),
              menuStyle: MenuStyle(
                backgroundColor: const WidgetStatePropertyAll(
                  AppColors.corInputs,
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              dropdownMenuEntries: categoriasDespesa.map((String value) {
                final bool isSelected = value == categoriaSelecionada;
                return DropdownMenuEntry<String>(
                  value: value,
                  label: value,
                  style: AppColors.dropdownMenuItemStyle(isSelected),
                );
              }).toList(),
              onSelected: (String? newValue) {
                if (newValue == null) return;
                setState(() => categoriaSelecionada = newValue);
              },
            );
          },
        ),
        const SizedBox(height: 20),
        const Text('Valor', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _valorController,
          hintText: 'Ex: 150,00',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [_valorInputFormatter],
        ),
        const SizedBox(height: 20),
        const Text('Descrição', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _descricaoController,
          hintText: 'Ex: Troca de óleo',
        ),
        const SizedBox(height: 20),
        const Text('Data', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _dataController,
          hintText: 'Selecione uma data',
          readOnly: true,
          suffixIcon: const Icon(Icons.calendar_today_outlined),
          onTap: _selecionarData,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    Widget? suffixIcon,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
    );
  }
}
