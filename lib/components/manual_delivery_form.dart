import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:motora_app/components/generic_modal.dart';
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
  final TextEditingController _quilometragemController = TextEditingController();
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
    if (entrega != null) {
      restauranteSelecionado = entrega.restaurante;
      if (!restaurantes.contains(entrega.restaurante)) {
        restaurantes.add(entrega.restaurante);
      }

      _valorController.text = entrega.valor.toStringAsFixed(2).replaceAll('.', ',');
      _quilometragemController.text = entrega.quilometragem.toString().replaceAll('.', ',');
      _dataController.text = DateFormat('dd/MM/yyyy').format(entrega.data);
    } else {
      _dataController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    }
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
        initialDate = DateFormat('dd/MM/yyyy').parseStrict(_dataController.text);
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

  Future<void> _saveDelivery() async {
    try {
      final parsedDate = DateFormat('dd/MM/yyyy').parseStrict(_dataController.text);
      final now = DateTime.now();

      DateTime dataFinal;
      if (widget.isEditing &&
          widget.entrega != null &&
          widget.entrega!.data.year == parsedDate.year &&
          widget.entrega!.data.month == parsedDate.month &&
          widget.entrega!.data.day == parsedDate.day) {
        dataFinal = widget.entrega!.data;
      } else {
        dataFinal = DateTime(
          parsedDate.year,
          parsedDate.month,
          parsedDate.day,
          now.hour,
          now.minute,
          now.second,
        );
      }

      final entrega = Entrega(
        id: widget.entrega?.id,
        restaurante: restauranteSelecionado!,
        valor: double.parse(_valorController.text.replaceAll(',', '.')),
        quilometragem: double.parse(_quilometragemController.text.replaceAll(',', '.')),
        data: dataFinal,
        userId: FirebaseAuth.instance.currentUser!.uid,
      );

      if (widget.isEditing) {
        await FirestoreService().atualizarEntrega(entrega);
      } else {
        await FirestoreService().salvarEntregaManual(entrega);
      }

      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
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
      if (!mounted) return;

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
  }

  @override
  Widget build(BuildContext context) {
    return GenericModal(
      title: widget.isEditing ? 'Editar Entrega' : 'Cadastrar Entrega',
      content: _buildContent(),
      confirmButtonText: widget.isEditing ? 'Salvar' : 'Cadastrar',
      confirmButtonIcon: const Icon(
        Icons.check_circle_outline,
        color: AppColors.corIcone,
      ),
      confirmButtonAction: _saveDelivery,
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
                        AppColors.corMaterial,
                      ),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    dropdownMenuEntries: restaurantes.map((String value) {
                      final bool isSelected = value == restauranteSelecionado;

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
        const Text('Valor', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _valorController,
          hintText: 'Ex: R\$ 18,50',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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