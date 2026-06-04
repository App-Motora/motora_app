import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:motora_app/components/generic_modal.dart';
import 'package:motora_app/components/restaurant_form.dart';
import 'package:motora_app/constants/app_colors.dart';
import 'package:motora_app/controllers/delivery_tracking_controller.dart';
import 'package:motora_app/models/delivery_model.dart';
import 'package:motora_app/models/delivery_tracking_result_model.dart';
import 'package:motora_app/models/restaurant_model.dart';
import 'package:motora_app/services/firestore_service.dart';
import 'package:motora_app/services/google_maps_service.dart';

class AutomaticDeliveryForm extends StatefulWidget {
  final String? initialRestaurant;

  const AutomaticDeliveryForm({super.key, this.initialRestaurant});

  @override
  State<AutomaticDeliveryForm> createState() => _AutomaticDeliveryFormState();
}

class _AutomaticDeliveryFormState extends State<AutomaticDeliveryForm> {
  final DeliveryTrackingController _trackingController =
      DeliveryTrackingController();
  final FirestoreService _firestoreService = FirestoreService();

  late final Stream<List<RestaurantModel>> _restaurantsStream;

  String? _selectedRestaurantId;
  String? _selectedRestaurantName;
  PaymentProfile? _activePaymentProfile;
  DeliveryTrackingResult? _finishedResult;
  double? _valorFinalCorrida;
  double? _distanciaFinalLimpa;
  bool _isFinishing = false;

  @override
  void initState() {
    super.initState();
    _restaurantsStream = _firestoreService.buscarRestaurantes();

    final initialRestaurant = widget.initialRestaurant;
    if (initialRestaurant != null && initialRestaurant.isNotEmpty) {
      _selectedRestaurantName = initialRestaurant;
    }

    _trackingController.addListener(_refreshTrackingState);
  }

  @override
  void dispose() {
    _trackingController.removeListener(_refreshTrackingState);
    _trackingController.dispose();
    super.dispose();
  }

  void _refreshTrackingState() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _startDelivery(RestaurantModel restaurant) async {
    final paymentProfile = restaurant.perfilPagamento;

    if (!paymentProfile.estaConfigurado) {
      _showMessage(
        'Configure o perfil de pagamento deste restaurante.',
        AppColors.corErro,
      );
      return;
    }

    _activePaymentProfile = paymentProfile;

    await _trackingController.start(
      restaurant: restaurant.nome,
      paymentProfile: paymentProfile.resumo,
    );

    if (!mounted) return;

    final errorMessage = _trackingController.errorMessage;
    if (errorMessage != null) {
      _activePaymentProfile = null;
      _showMessage(errorMessage, AppColors.corErro);
    }
  }

  Future<void> _finishDelivery() async {
    setState(() {
      _isFinishing = true;
    });

    try {
      final rawResult = await _trackingController.finish();

      final googleMapsService = GoogleMapsService();
      final quilometragemLimpa = await googleMapsService.calcularDistanciaReal(
        rawResult.path,
      );

      final paymentProfile = _activePaymentProfile;
      if (paymentProfile == null || !paymentProfile.estaConfigurado) {
        throw Exception('Perfil de pagamento nao encontrado.');
      }

      final valorCalculado = _roundCurrency(
        paymentProfile.calcularValorEntrega(quilometragemLimpa),
      );
      final quilometragemCalculada = double.parse(
        quilometragemLimpa.toStringAsFixed(2),
      );

      final novaEntrega = Entrega(
        id: '',
        restaurante: rawResult.restaurant,
        valor: valorCalculado,
        quilometragem: quilometragemCalculada,
        data: rawResult.endedAt,
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      );

      await _firestoreService.salvarEntregaAutomatica(novaEntrega);

      if (!mounted) return;

      setState(() {
        _finishedResult = rawResult;
        _valorFinalCorrida = valorCalculado;
        _distanciaFinalLimpa = quilometragemCalculada;
      });

      _showMessage('Entrega salva com sucesso!', AppColors.corSucesso);
    } catch (e) {
      if (!mounted) return;
      _showMessage(
        'Erro ao processar ou salvar entrega: $e',
        AppColors.corErro,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isFinishing = false;
        });
      }
    }
  }

  Future<void> _closeDialog() async {
    if (_trackingController.isTracking) {
      final shouldClose = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppColors.corFundo,
            title: const Text('Cancelar entrega?'),
            content: const Text(
              'A entrega em andamento sera encerrada sem gerar o path final.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Voltar',
                  style: TextStyle(color: AppColors.corTexto),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: AppColors.corExcluir),
                ),
              ),
            ],
          );
        },
      );

      if (shouldClose != true || !mounted) return;
    }

    Navigator.pop(context);
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return GenericModal(
      title: _dialogTitle,
      content: _buildDialogBody(),
      onClose: _closeDialog,
      showActions: false,
      padding: const EdgeInsets.all(20.0),
      contentSpacing: 8,
    );
  }

  String get _dialogTitle {
    if (_finishedResult != null) return 'Entrega finalizada';
    if (_trackingController.isTracking || _isFinishing) {
      return 'Entrega em andamento';
    }
    return 'Iniciar Entrega';
  }

  Widget _buildDialogBody() {
    if (_finishedResult != null) {
      return _buildResultView(_finishedResult!);
    }
    if (_trackingController.isTracking || _isFinishing) {
      return _buildTrackingView();
    }

    return _buildStartForm();
  }

  Widget _buildStartForm() {
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

        return _buildStartFormContent(restaurants, selectedRestaurant);
      },
    );
  }

  Widget _buildStartFormContent(
    List<RestaurantModel> restaurants,
    RestaurantModel? selectedRestaurant,
  ) {
    final isStarting = _trackingController.isStarting;
    final hasRestaurants = restaurants.isNotEmpty;
    final hasPaymentProfile =
        selectedRestaurant?.perfilPagamento.estaConfigurado ?? false;
    final canStart =
        !isStarting && selectedRestaurant != null && hasPaymentProfile;

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
                    enabled: !isStarting && hasRestaurants,
                    width: constraints.maxWidth,
                    initialSelection: selectedRestaurant == null
                        ? null
                        : _restaurantKey(selectedRestaurant),
                    textStyle: const TextStyle(
                      color: AppColors.corTexto,
                      fontSize: 15,
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
                      final isSelected =
                          selectedRestaurant != null &&
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
                color: isStarting
                    ? AppColors.corBordaInputs
                    : AppColors.corBordaFocadaInputs,
                borderRadius: BorderRadius.circular(25),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: AppColors.corIcone),
                onPressed: isStarting ? null : _openCreateRestaurantModal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Perfil de Pagamento',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        _buildPaymentProfileInfo(
          selectedRestaurant,
          hasRestaurants: hasRestaurants,
        ),
        if (selectedRestaurant != null && !hasPaymentProfile) ...[
          const SizedBox(height: 8),
          const Text(
            'Configure o perfil deste restaurante antes de iniciar.',
            style: TextStyle(color: AppColors.corErro, fontSize: 12),
          ),
        ],
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: canStart
                    ? () => _startDelivery(selectedRestaurant)
                    : null,
                icon: isStarting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.corIcone,
                        ),
                      )
                    : const Icon(
                        Icons.play_arrow_outlined,
                        color: AppColors.corIcone,
                      ),
                label: Text(
                  isStarting ? 'Iniciando...' : 'Iniciar Entrega',
                  style: const TextStyle(color: AppColors.corTexto),
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
                onPressed: isStarting ? null : _closeDialog,
                style: _secondaryButtonStyle(),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: AppColors.corTexto),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrackingView() {
    final controller = _trackingController;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReadOnlyInfo('Restaurante', controller.restaurant ?? ''),
        const SizedBox(height: 12),
        _buildReadOnlyInfo(
          'Perfil de Pagamento',
          controller.paymentProfile ?? '',
        ),
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              const Text(
                'Quilometros rodados',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                '${controller.distanceLabelKm} km',
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: AppColors.corSecundaria,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: controller.isPaused
                    ? controller.resume
                    : controller.pause,
                icon: Icon(
                  controller.isPaused ? Icons.play_arrow : Icons.pause,
                  color: AppColors.corIcone,
                ),
                label: Text(
                  controller.isPaused ? 'Retomar' : 'Pausar',
                  style: const TextStyle(color: AppColors.corTexto),
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
              child: OutlinedButton.icon(
                onPressed: _isFinishing ? null : _finishDelivery,
                icon: _isFinishing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.corErro,
                        ),
                      )
                    : const Icon(
                        Icons.stop_circle_outlined,
                        color: AppColors.corErro,
                      ),
                label: Text(
                  _isFinishing ? 'Calculando...' : 'Finalizar',
                  style: const TextStyle(color: AppColors.corErro),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.corInputs,
                  side: const BorderSide(color: AppColors.corErro, width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (controller.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            controller.errorMessage!,
            style: const TextStyle(color: AppColors.corErro),
          ),
        ],
      ],
    );
  }

  Widget _buildResultView(DeliveryTrackingResult result) {
    final double distancia = _distanciaFinalLimpa ?? result.totalDistanceKm;
    final double valor = _valorFinalCorrida ?? 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReadOnlyInfo('Restaurante', result.restaurant),
        const SizedBox(height: 12),
        _buildReadOnlyInfo('Perfil de Pagamento', result.paymentProfile),
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              const Text(
                'Quilometros rodados',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                '${distancia.toStringAsFixed(1)} km',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.corSecundaria,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Valor da corrida',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.corEntrega,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, result),
            icon: const Icon(
              Icons.check_circle_outline,
              color: AppColors.corIcone,
            ),
            label: const Text(
              'Fechar',
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
      ],
    );
  }

  Widget _buildPaymentProfileInfo(
    RestaurantModel? restaurant, {
    required bool hasRestaurants,
  }) {
    final text = restaurant == null
        ? hasRestaurants
              ? 'Selecione um restaurante'
              : 'Cadastre um restaurante para iniciar'
        : restaurant.perfilPagamento.resumo;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.corBordaInputs,
      ),
      child: Text(text, style: const TextStyle(color: AppColors.corTexto)),
    );
  }

  Widget _buildReadOnlyInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.corBordaInputs,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.corBordaInputs),
          ),
          child: Text(value, style: const TextStyle(color: AppColors.corTexto)),
        ),
      ],
    );
  }

  ButtonStyle _secondaryButtonStyle() {
    return OutlinedButton.styleFrom(
      backgroundColor: AppColors.corInputs,
      side: BorderSide(color: AppColors.corBordaInputs, width: 1),
      padding: const EdgeInsets.symmetric(vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      overlayColor: AppColors.corOverlayBotaoCancelar,
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
          onPressed: _closeDialog,
          style: _secondaryButtonStyle(),
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

    final initialRestaurant = widget.initialRestaurant;
    if (initialRestaurant != null && initialRestaurant.trim().isNotEmpty) {
      final restaurant = _findRestaurantByName(restaurants, initialRestaurant);
      if (restaurant != null) return restaurant;
    }

    return restaurants.first;
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

  double _roundCurrency(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  void _openCreateRestaurantModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) => const RestaurantForm(),
    );
  }
}
