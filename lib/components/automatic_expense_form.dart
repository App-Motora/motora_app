import 'package:flutter/material.dart';
import 'package:motora_app/components/generic_modal.dart';
import 'package:motora_app/constants/app_colors.dart';

class AutomaticExpenseForm extends StatefulWidget {
  const AutomaticExpenseForm({super.key});

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

  final TextEditingController _valorController = TextEditingController(
    text: 'R\$0,00',
  );
  final TextEditingController _descricaoController = TextEditingController();

  @override
  void dispose() {
    _valorController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GenericModal(
      title: 'Cadastrar Despesa',
      content: _buildContent(),
      confirmButtonText: 'Salvar Despesa',
      confirmButtonIcon: const Icon(
        Icons.check_circle_outline,
        color: AppColors.corIcone,
      ),
      confirmButtonAction: () {},
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
        _buildTextField(controller: _valorController),
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
  }) {
    return TextField(
      controller: controller,
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
