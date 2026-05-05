import 'package:flutter/material.dart';

class AutomaticDeliveryForm extends StatefulWidget {
  @override
  State<AutomaticDeliveryForm> createState() => _AutomaticDeliveryFormState();
}

class _AutomaticDeliveryFormState extends State<AutomaticDeliveryForm> {
  String? restauranteSelecionado = 'Açaí da Praia';
  final List<String> restaurantes = [
    'Açaí da Praia',
    'Pizzaria do Bairro',
    'Hambúrguer Caseiro',
  ];

  final TextEditingController _pagamentoController = TextEditingController(
    text: 'R\$3,00/km',
  );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Color(0xFFF2EDE4),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 24),
                  Text(
                    'Iniciar Entrega',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Text(
                'Restaurante',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return DropdownMenu<String>(
                          width: constraints.maxWidth,
                          initialSelection: restauranteSelecionado,
                          textStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                          menuStyle: MenuStyle(
                            backgroundColor: const WidgetStatePropertyAll(
                              Colors.white,
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
                          inputDecorationTheme: InputDecorationTheme(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                          ),
                          dropdownMenuEntries: restaurantes.map((String value) {
                            final bool isSelected =
                                value == restauranteSelecionado;

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
                                      return Colors.white;
                                    }),
                                foregroundColor: const WidgetStatePropertyAll(
                                  Colors.black,
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
                              restauranteSelecionado = newValue;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3D080),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.black),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              Text(
                'Perfil de Pagamento',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: TextField(
                  controller: _pagamentoController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(
                        Icons.play_arrow_outlined,
                        color: Colors.black,
                      ),
                      label: Text(
                        'Iniciar Entrega',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF3D080),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        side: BorderSide(color: Colors.grey.shade300, width: 1),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        overlayColor: Colors.grey,
                      ),
                      child: Text(
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
}
