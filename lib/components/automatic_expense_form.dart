import 'package:flutter/material.dart';
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.corFundo,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 24),
                  const Text(
                    'Cadastrar Despesa',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.corTexto,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.corIcone),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
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
                          dropdownMenuEntries: categoriasDespesa.map((
                            String value,
                          ) {
                            final bool isSelected =
                                value == categoriaSelecionada;

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
              const Text(
                'Descricao',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _descricaoController,
                hintText: 'Ex: Abastecimento do turno',
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.corIcone,
                      ),
                      label: const Text(
                        'Salvar Despesa',
                        style: TextStyle(color: AppColors.corTexto),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.corBordaFocadaInputs,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.corInputs,
                        side: BorderSide(color: AppColors.corBordaInputs, width: 1),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        overlayColor: AppColors.corOverlayBotaoCancelar,
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: AppColors.corTexto),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
        )
      ),
    );
  }
}
