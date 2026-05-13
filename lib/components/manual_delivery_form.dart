import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:motora_app/constants/app_colors.dart';
import 'package:motora_app/models/delivery_model.dart';
import 'package:motora_app/services/firestore_service.dart';
import 'package:intl/intl.dart';

class ManualDeliveryForm extends StatefulWidget {
  final Entrega? entrega;

  const ManualDeliveryForm({super.key, this.entrega});

  bool get isEditing => entrega != null;

  @override
  State<ManualDeliveryForm> createState() => _ManualDeliveryFormState();
}

class _ManualDeliveryFormState extends State<ManualDeliveryForm> {
  String? restauranteSelecionado = 'Acai da Praia';
  final List<String> restaurantes = [
    'Acai da Praia',
    'Pizzaria do Bairro',
    'Hamburguer Caseiro',
  ];

  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _quilometragemController =
      TextEditingController();
  final TextEditingController _dataController = TextEditingController();

  final TextInputFormatter _valorInputFormatter =
      TextInputFormatter.withFunction((oldValue, newValue) {
        final RegExp regex = RegExp(r'^\d*([.,]\d{0,2})?$');
        return regex.hasMatch(newValue.text) ? newValue : oldValue;
      });

  final TextInputFormatter _quilometragemInputFormatter =
      TextInputFormatter.withFunction((oldValue, newValue) {
        final RegExp regex = RegExp(r'^\d*([.,]\d{0,3})?$');
        return regex.hasMatch(newValue.text) ? newValue : oldValue;
      });

  @override
  void initState() {
    super.initState();

    final entrega = widget.entrega;
    if (entrega == null) return;

    restauranteSelecionado = entrega.restaurante;
    if (!restaurantes.contains(entrega.restaurante)) {
      restaurantes.add(entrega.restaurante);
    }

    _valorController.text = entrega.valor
        .toStringAsFixed(2)
        .replaceAll('.', ',');
    _quilometragemController.text = entrega.quilometragem.toString().replaceAll(
      '.',
      ',',
    );
    _dataController.text = DateFormat('dd/MM/yyyy').format(entrega.data);
  }

  @override
  void dispose() {
    _valorController.dispose();
    _quilometragemController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final DateTime now = DateTime.now();
    DateTime initialDate = widget.entrega?.data ?? now;
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
                  Text(
                    widget.isEditing ? 'Editar Entrega' : 'Cadastrar Entrega',
                    style: const TextStyle(
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
                'Restaurante',
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
                          initialSelection: restauranteSelecionado,
                          textStyle: const TextStyle(
                            color: AppColors.corTexto,
                            fontSize: 16,
                          ),
                          menuStyle: MenuStyle(
                            backgroundColor: const WidgetStatePropertyAll(
                              AppColors.corInputs,
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
                          dropdownMenuEntries: restaurantes.map((String value) {
                            final bool isSelected =
                                value == restauranteSelecionado;

                            return DropdownMenuEntry<String>(
                              value: value,
                              label: value,
                              style: AppColors.dropdownMenuItemStyle(isSelected),
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
                'Valor',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _valorController,
                hintText: 'Ex: R\$ 18,50',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [_valorInputFormatter],
              ),
              const SizedBox(height: 20),
              const Text(
                'Quilometragem',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _quilometragemController,
                hintText: 'Ex: 7.4 km',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [_quilometragemInputFormatter],
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
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          final dataFormatada = DateFormat(
                            'dd/MM/yyyy',
                          ).parseStrict(_dataController.text);

                          final entrega = Entrega(
                            id: widget.entrega?.id,
                            restaurante: restauranteSelecionado!,
                            valor: double.parse(
                              _valorController.text.replaceAll(',', '.'),
                            ),
                            quilometragem: double.parse(
                              _quilometragemController.text.replaceAll(
                                ',',
                                '.',
                              ),
                            ),
                            data: dataFormatada,
                            userId: FirebaseAuth.instance.currentUser!.uid,
                          );

                          if (widget.isEditing) {
                            await FirestoreService().atualizarEntrega(entrega);
                          } else {
                            await FirestoreService().salvarEntregaManual(
                              entrega,
                            );
                          }

                          if (!context.mounted) return;

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                widget.isEditing
                                    ? 'Entrega atualizada com sucesso!'
                                    : 'Entrega cadastrada com sucesso!',
                              ),
                              backgroundColor: AppColors.corSucesso,
                            ),
                          );
                        } catch (e) {
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                widget.isEditing
                                    ? 'Erro ao atualizar. Verifique os campos.'
                                    : 'Erro ao cadastrar. Verifique os campos.',
                              ),
                              backgroundColor: AppColors.corErro,
                            ),
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.corIcone,
                      ),
                      label: Text(
                        widget.isEditing ? 'Salvar' : 'Cadastrar',
                        style: const TextStyle(color: AppColors.corTexto),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.corPrincipal,
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
        )
      ),
    );
  }
}
