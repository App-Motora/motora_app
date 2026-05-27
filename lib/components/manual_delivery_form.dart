import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:motora_app/components/generic_modal.dart';
import 'package:motora_app/components/restaurant_form.dart';
import 'package:motora_app/constants/app_colors.dart';
import 'package:motora_app/models/delivery_model.dart';
import 'package:motora_app/models/restaurant_model.dart';
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
  final FirestoreService _firestoreService = FirestoreService();
  
  late final Stream<List<RestaurantModel>> _restaurantsStream;

  String? _selectedRestaurantId;
  String? _selectedRestaurantName;
  RestaurantModel? _selectedRestaurant;

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

    _restaurantsStream = _firestoreService.buscarRestaurantes();

    final entrega = widget.entrega;
    if (entrega == null) return;

    _selectedRestaurantName = entrega.restaurante;

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
    return StreamBuilder<List<RestaurantModel>>(
      stream: _restaurantsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildRestaurantsLoading();
        }

        if (snapshot.hasError) {
          return _buildRestaurantsError();
        }

        final restaurants = snapshot.data ?? [];
        final selectedRestaurant = _resolveSelectedRestaurant(restaurants);

        return _buildFormContent(restaurants, selectedRestaurant);
      },
    );
  }

  Widget _buildFormContent(
    List<RestaurantModel> restaurants,
    RestaurantModel? selectedRestaurant,
  ) {
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
                    initialSelection: selectedRestaurant == null
                        ? null
                        : _restaurantKey(selectedRestaurant),
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
                    dropdownMenuEntries: restaurants.map((restaurant) {
                      final value = _restaurantKey(restaurant);
                      final isSelected = selectedRestaurant != null &&
                          _isSameRestaurant(restaurant, selectedRestaurant);

                      return DropdownMenuEntry<String>(
                        value: value,
                        label: restaurant.nome,
                        style: AppColors.dropdownMenuItemStyle(isSelected),
                      );
                    }).toList(),
                    onSelected: (String? newValue) {
                      if (newValue == null) return;

                      final restaurant = _findRestaurantByKey(
                        restaurants,
                        newValue,
                      );

                      setState(() {
                        _selectedRestaurant = restaurant;
                        _selectedRestaurantId = restaurant?.id;
                        _selectedRestaurantName = restaurant?.nome ?? newValue;
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
                onPressed: () => showDialog(
                  context: context,
                  builder: (BuildContext context) => const RestaurantForm(),
                ),
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

  Future<void> _saveDelivery() async {
    try {
      final dataFormatada = DateFormat(
        'dd/MM/yyyy',
      ).parseStrict(_dataController.text);

      final restauranteName = _selectedRestaurantName;
      if (restauranteName == null || restauranteName.isEmpty) {
        _showError('Selecione um restaurante');
        return;
      }

      final entrega = Entrega(
        id: widget.entrega?.id,
        restaurante: restauranteName,
        valor: double.parse(_valorController.text.replaceAll(',', '.')),
        quilometragem: double.parse(
          _quilometragemController.text.replaceAll(',', '.'),
        ),
        data: dataFormatada,
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
      _showError(
        widget.isEditing
            ? 'Erro ao atualizar. Verifique os campos.'
            : 'Erro ao cadastrar. Verifique os campos.',
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.corErro,
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
        ),
      ),
    );
  }

  Widget _buildRestaurantsLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: CircularProgressIndicator(color: AppColors.corSecundaria),
      ),
    );
  }

  Widget _buildRestaurantsError() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Erro ao carregar restaurantes.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.corErro),
        ),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.corInputs,
            side: BorderSide(color: AppColors.corBordaInputs, width: 1),
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text(
            'Fechar',
            style: TextStyle(color: AppColors.corTexto),
          ),
        ),
      ],
    );
  }

  RestaurantModel? _resolveSelectedRestaurant(
    List<RestaurantModel> restaurants,
  ) {
    if (restaurants.isEmpty) return null;

    final selectedId = _selectedRestaurantId;
    if (selectedId != null) {
      final restaurant = _findRestaurantById(restaurants, selectedId);
      if (restaurant != null) return restaurant;
    }

    final selectedName = _selectedRestaurantName;
    if (selectedName != null && selectedName.trim().isNotEmpty) {
      final restaurant = _findRestaurantByName(restaurants, selectedName);
      if (restaurant != null) return restaurant;
    }

    return null;
  }

  RestaurantModel? _findRestaurantByKey(
    List<RestaurantModel> restaurants,
    String key,
  ) {
    for (final restaurant in restaurants) {
      if (_restaurantKey(restaurant) == key) return restaurant;
    }

    return _findRestaurantByName(restaurants, key);
  }

  RestaurantModel? _findRestaurantById(
    List<RestaurantModel> restaurants,
    String id,
  ) {
    for (final restaurant in restaurants) {
      if (restaurant.id == id) return restaurant;
    }
    return null;
  }

  RestaurantModel? _findRestaurantByName(
    List<RestaurantModel> restaurants,
    String name,
  ) {
    final normalizedName = _normalizeName(name);

    for (final restaurant in restaurants) {
      if (_normalizeName(restaurant.nome) == normalizedName) {
        return restaurant;
      }
    }

    return null;
  }

  bool _isSameRestaurant(RestaurantModel a, RestaurantModel b) {
    final aId = a.id;
    final bId = b.id;

    if (aId != null && bId != null) return aId == bId;
    return _normalizeName(a.nome) == _normalizeName(b.nome);
  }

  String _restaurantKey(RestaurantModel restaurant) {
    return restaurant.id ?? restaurant.nome;
  }

  String _normalizeName(String value) {
    return value.trim().toLowerCase();
  }
}
