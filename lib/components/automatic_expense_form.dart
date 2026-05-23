import 'package:flutter/material.dart';
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
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.despesaParaEditar != null) {
      final d = widget.despesaParaEditar!;
      categoriaSelecionada = categoriasDespesa.contains(d.categoria) ? d.categoria : categoriasDespesa.first;
      _descricaoController.text = d.descricao;
      _valorController.text = d.valor.toStringAsFixed(2).replaceAll('.', ',');
    } else {
      _valorController.text = 'R\$ 0,00';
    }
  }

  @override
  void dispose() {
    _valorController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _salvarDespesa() async {
    final valorString = _valorController.text
        .replaceAll('R\$', '')
        .replaceAll('.', '') 
        .replaceAll(',', '.')
        .trim();
        
    final double? valorNum = double.tryParse(valorString);
    final descricaoText = _descricaoController.text.trim();
    if (valorNum == null || valorNum <= 0 || descricaoText.isEmpty || categoriaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, informe um valor e uma descrição válidos.'),
          backgroundColor: AppColors.corErro,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final despesa = Despesa(
        id: widget.despesaParaEditar?.id, 
        categoria: categoriaSelecionada!,
        descricao: descricaoText,
        valor: valorNum,
        data: widget.despesaParaEditar?.data ?? DateTime.now(), 
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      );

      final firestoreService = FirestoreService();
      if (widget.despesaParaEditar == null) {
        await firestoreService.salvarDespesa(despesa);
      } else {
        await firestoreService.atualizarDespesa(despesa);
      }

      if (!mounted) return;

      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Despesa salva com sucesso!'),
          backgroundColor: AppColors.corSucesso,
        ),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: AppColors.corErro),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GenericModal(
      title: widget.despesaParaEditar == null ? 'Cadastrar Despesa' : 'Editar Despesa',
      content: _buildContent(),
      confirmButtonText: _isSaving ? 'Salvando...' : 'Salvar Despesa',
      confirmButtonIcon: _isSaving 
          ? const SizedBox(
              width: 18, height: 18, 
              child: CircularProgressIndicator(color: AppColors.corIcone, strokeWidth: 2)
            )
          : const Icon(Icons.check_circle_outline, color: AppColors.corIcone),
      confirmButtonAction: _isSaving ? null : _salvarDespesa,
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
        Row(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return DropdownMenu<String>(
                    width: constraints.maxWidth,
                    initialSelection: categoriaSelecionada,
                    textStyle: const TextStyle(
                      color: AppColors.corTexto,
                      fontSize: 15,
                    ),
                    menuStyle: MenuStyle(
                      backgroundColor: const WidgetStatePropertyAll(AppColors.corInputs),
                      surfaceTintColor: const WidgetStatePropertyAll(AppColors.corMaterial),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      setState(() {
                        categoriaSelecionada = newValue;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.corPrincipal,
                borderRadius: BorderRadius.circular(25),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: AppColors.corIcone),
                onPressed: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Valor da Despesa',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _valorController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 20),
        const Text('Descricao', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _descricaoController,
          hintText: 'Ex: Abastecimento do turno',
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hintText,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
    );
  }
}