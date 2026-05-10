import 'package:flutter/material.dart';

class AutomaticExpenseForm extends StatefulWidget {
  const AutomaticExpenseForm({super.key});

  @override
  State<AutomaticExpenseForm> createState() => _AutomaticExpenseFormState();
}

class _AutomaticExpenseFormState extends State<AutomaticExpenseForm> {
  static const Color _modalBackgroundColor = Color(0xFFF2EDE4);
  static const Color _fieldBackgroundColor = Colors.white;
  static const Color _accentColor = Color(0xFFF3D080);
  static const Color _textColor = Color(0xFF333333);

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
          color: _modalBackgroundColor,
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
                      color: _textColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
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
                          textStyle: const TextStyle(
                            color: _textColor,
                            fontSize: 16,
                          ),
                          menuStyle: MenuStyle(
                            backgroundColor: const WidgetStatePropertyAll(
                              _fieldBackgroundColor,
                            ),
                            surfaceTintColor: const WidgetStatePropertyAll(
                              Colors.transparent,
                            ),
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          dropdownMenuEntries: categoriasDespesa.map((
                            String value,
                          ) {
                            final bool isSelected =
                                value == categoriaSelecionada;

                            return DropdownMenuEntry<String>(
                              value: value,
                              label: value,
                              style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.resolveWith((states) {
                                      if (isSelected) {
                                        return const Color(0xFFF1F1F1);
                                      }
                                      if (states.contains(
                                        WidgetState.selected,
                                      )) {
                                        return const Color(0xFFF6F6F6);
                                      }
                                      if (states.contains(
                                        WidgetState.hovered,
                                      )) {
                                        return const Color(0xFFF8F8F8);
                                      }
                                      return _fieldBackgroundColor;
                                    }),
                                foregroundColor: const WidgetStatePropertyAll(
                                  _textColor,
                                ),
                                overlayColor: const WidgetStatePropertyAll(
                                  Color(0x1AF3D080),
                                ),
                              ),
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
                      color: _accentColor,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.black),
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
                        color: Colors.black,
                      ),
                      label: const Text(
                        'Salvar Despesa',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3D080),
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
                        backgroundColor: Colors.grey.shade200,
                        side: BorderSide(color: Colors.grey.shade300, width: 1),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        overlayColor: Colors.grey,
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.black),
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
