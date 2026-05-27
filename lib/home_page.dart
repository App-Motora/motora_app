import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motora_app/components/activity_card.dart';
import 'package:motora_app/components/automatic_delivery_form.dart';
import 'package:motora_app/components/automatic_expense_form.dart';
import 'package:motora_app/components/float_button.dart';
import 'package:motora_app/components/generic_modal.dart';
import 'package:motora_app/components/header.dart';
import 'package:motora_app/components/menu.dart';
import 'package:motora_app/constants/app_colors.dart';
import 'package:motora_app/home_page_vazia.dart';
import 'package:motora_app/models/delivery_model.dart';
import 'package:motora_app/models/expense_model.dart';
import 'package:motora_app/models/restaurant_model.dart';
import 'package:motora_app/models/shift_model.dart';
import 'package:motora_app/services/firestore_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final int _activeMenuIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _selectedRestaurant;
  String? _shiftStartRestaurant;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.corFundo,
      drawer: Menu(selectedIndex: _activeMenuIndex),
      body: SafeArea(
        child: StreamBuilder<List<RestaurantModel>>(
          stream: FirestoreService().buscarRestaurantes(),
          builder: (context, restaurantesSnapshot) {
            final restaurantes = _restaurantNames(
              restaurantesSnapshot.data ?? [],
            );

            return StreamBuilder<Turno?>(
              stream: FirestoreService().buscarTurnoAtivo(),
              builder: (context, turnoSnapshot) {
                return StreamBuilder<Entrega?>(
                  stream: FirestoreService().buscarEntregaMaisRecente(),
                  builder: (context, entregaRecenteSnapshot) {
                    final turnoAtivo = turnoSnapshot.data;
                    final restauranteAtual = _resolveCurrentRestaurant(
                      turnoAtivo: turnoAtivo,
                      entregaRecente: entregaRecenteSnapshot.data,
                      restaurantes: restaurantes,
                    );

                    return StreamBuilder<List<Entrega>>(
                      stream: FirestoreService().buscarEntregasDoDia(),
                      builder: (context, entregasSnapshot) {
                        return StreamBuilder<List<Despesa>>(
                          stream: FirestoreService().buscarDespesasDoDia(),
                          builder: (context, despesasSnapshot) {
                            final entregas = entregasSnapshot.data ?? [];
                            final despesas = despesasSnapshot.data ?? [];

                            if (turnoAtivo == null) {
                              return _buildHomeContent(
                                turnoAtivo: null,
                                entregasTurno: const [],
                                restauranteAtual: restauranteAtual,
                                restaurantes: restaurantes,
                                restaurantesSnapshot: restaurantesSnapshot,
                                entregasSnapshot: entregasSnapshot,
                                despesasSnapshot: despesasSnapshot,
                                entregas: entregas,
                                despesas: despesas,
                              );
                            }

                            return StreamBuilder<List<Entrega>>(
                              stream: FirestoreService().buscarEntregasDesde(
                                turnoAtivo.iniciadoEm,
                              ),
                              builder: (context, entregasTurnoSnapshot) {
                                return _buildHomeContent(
                                  turnoAtivo: turnoAtivo,
                                  entregasTurno:
                                      entregasTurnoSnapshot.data ?? const [],
                                  restauranteAtual: restauranteAtual,
                                  restaurantes: restaurantes,
                                  restaurantesSnapshot: restaurantesSnapshot,
                                  entregasSnapshot: entregasSnapshot,
                                  despesasSnapshot: despesasSnapshot,
                                  entregas: entregas,
                                  despesas: despesas,
                                  isShiftDeliveriesLoading:
                                      entregasTurnoSnapshot.connectionState ==
                                      ConnectionState.waiting,
                                  hasShiftDeliveriesError:
                                      entregasTurnoSnapshot.hasError,
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHomeContent({
    required Turno? turnoAtivo,
    required List<Entrega> entregasTurno,
    required String restauranteAtual,
    required List<String> restaurantes,
    required AsyncSnapshot<List<RestaurantModel>> restaurantesSnapshot,
    required AsyncSnapshot<List<Entrega>> entregasSnapshot,
    required AsyncSnapshot<List<Despesa>> despesasSnapshot,
    required List<Entrega> entregas,
    required List<Despesa> despesas,
    bool isShiftDeliveriesLoading = false,
    bool hasShiftDeliveriesError = false,
  }) {
    final isLoading =
        entregasSnapshot.connectionState == ConnectionState.waiting ||
        despesasSnapshot.connectionState == ConnectionState.waiting ||
        restaurantesSnapshot.connectionState == ConnectionState.waiting ||
        isShiftDeliveriesLoading;
    final hasError =
        entregasSnapshot.hasError ||
        despesasSnapshot.hasError ||
        restaurantesSnapshot.hasError ||
        hasShiftDeliveriesError;
    final activities = _buildDailyActivities(entregas, despesas);
    final hasActivities = activities.isNotEmpty;
    final totalEntregas = entregas.fold<double>(
      0,
      (total, entrega) => total + entrega.valor,
    );
    final totalDespesas = despesas.fold<double>(
      0,
      (total, despesa) => total + despesa.valor,
    );
    final saldo = totalEntregas - totalDespesas;
    final hasActiveShift = turnoAtivo != null;
    final shiftDeliveryCount = hasActiveShift
        ? _countShiftRestaurantDeliveries(turnoAtivo, entregasTurno)
        : 0;

    return Stack(
      children: [
        Column(
          children: [
            Header(
              selectedRestaurant: restauranteAtual,
              restaurants: restaurantes,
              hasActiveShift: hasActiveShift,
              shiftDeliveryCount: shiftDeliveryCount,
              receitas: totalEntregas,
              despesas: totalDespesas,
              saldo: saldo,
              onMenuPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              onRestaurantSelected: (restaurant) {
                setState(() {
                  _selectedRestaurant = restaurant;
                });
              },
              onFinishShiftPressed: turnoAtivo == null
                  ? null
                  : () => _openFinishShiftModal(turnoAtivo, entregasTurno),
            ),
            Expanded(
              child: _buildBody(
                isLoading: isLoading,
                hasError: hasError,
                hasActivities: hasActivities,
                activities: activities,
                selectedRestaurant: restauranteAtual,
                restaurants: restaurantes,
                hasActiveShift: hasActiveShift,
              ),
            ),
          ],
        ),
        if (hasActivities && !isLoading && !hasError)
          Positioned(
            bottom: 30,
            right: 20,
            child: _buildFloatingActionMenu(
              hasActiveShift: hasActiveShift,
              selectedRestaurant: restauranteAtual,
              restaurants: restaurantes,
            ),
          ),
      ],
    );
  }

  Widget _buildBody({
    required bool isLoading,
    required bool hasError,
    required bool hasActivities,
    required List<_DailyActivity> activities,
    required String selectedRestaurant,
    required List<String> restaurants,
    required bool hasActiveShift,
  }) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.corSecundaria),
      );
    }

    if (hasError) {
      return const Center(
        child: Text('Erro ao carregar as atividades de hoje.'),
      );
    }

    if (!hasActivities) {
      return HomePageVazia(
        initialRestaurant: selectedRestaurant,
        hasActiveShift: hasActiveShift,
        onStartShiftPressed: () => _openStartShiftModal(
          selectedRestaurant: selectedRestaurant,
          restaurants: restaurants,
        ),
      );
    }

    return _buildActivityList(activities);
  }

  List<_DailyActivity> _buildDailyActivities(
    List<Entrega> entregas,
    List<Despesa> despesas,
  ) {
    final activities = <_DailyActivity>[
      ...entregas.map(_DailyActivity.fromDelivery),
      ...despesas.map(_DailyActivity.fromExpense),
    ]..sort((a, b) => b.date.compareTo(a.date));

    return activities;
  }

  Widget _buildActivityList(List<_DailyActivity> activities) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const Center(
            child: Text(
              'Atividades de Hoje',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          ...activities.map(
            (activity) => ActivityCard(
              icon: activity.icon,
              iconBackgroundColor: activity.color,
              time: DateFormat('HH:mm').format(activity.date),
              title: activity.title,
              subtitle: activity.subtitle,
              amount: activity.amount,
              isPositive: activity.isPositive,
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildFloatingActionMenu({
    required bool hasActiveShift,
    required String selectedRestaurant,
    required List<String> restaurants,
  }) {
    return Column(
      children: [
        if (!hasActiveShift) ...[
          FloatButton(
            icon: Icons.access_time,
            color: AppColors.corSecundaria,
            function: () => _openStartShiftModal(
              selectedRestaurant: selectedRestaurant,
              restaurants: restaurants,
            ),
          ),
          const SizedBox(height: 12),
        ],
        FloatButton(
          icon: Icons.swap_vert,
          color: AppColors.corDespesa,
          function: () => showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AutomaticExpenseForm();
            },
          ),
        ),
        const SizedBox(height: 12),
        FloatButton(
          icon: Icons.delivery_dining,
          color: AppColors.corEntrega,
          function: () => showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AutomaticDeliveryForm(
                initialRestaurant: selectedRestaurant,
              );
            },
          ),
        ),
      ],
    );
  }

  void _openStartShiftModal({
    required String selectedRestaurant,
    required List<String> restaurants,
  }) {
    _shiftStartRestaurant = selectedRestaurant;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GenericModal(
          title: 'Começar um turno?',
          content: _buildStartShiftContent(restaurants),
          confirmButtonText: 'Iniciar Turno',
          confirmButtonIcon: Icon(
            Icons.play_arrow_outlined,
            color: AppColors.corIcone,
          ),
          confirmButtonAction: _startShift,
        );
      },
    );
  }

  Future<void> _startShift() async {
    final restaurant = _shiftStartRestaurant;
    if (restaurant == null) return;

    try {
      await FirestoreService().iniciarTurno(restaurant);

      if (!mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Turno iniciado com sucesso!'),
          backgroundColor: AppColors.corSucesso,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao iniciar turno.'),
          backgroundColor: AppColors.corErro,
        ),
      );
    }
  }

  Widget _buildStartShiftContent(List<String> restaurants) {
    _shiftStartRestaurant = _resolveRestaurantFromList(
      _shiftStartRestaurant,
      restaurants,
    );

    return StatefulBuilder(
      builder: (context, setModalState) {
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
                      return DropdownButtonFormField<String>(
                        initialValue:
                            restaurants.contains(_shiftStartRestaurant)
                            ? _shiftStartRestaurant
                            : null,
                        isExpanded: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.corInputs,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: restaurants.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue == null) return;

                          setModalState(() {
                            _shiftStartRestaurant = newValue;
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.corBordaFocadaInputs,
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
          ],
        );
      },
    );
  }

  void _openFinishShiftModal(Turno turno, List<Entrega> entregasTurno) {
    final entregasRestaurante = _countShiftRestaurantDeliveries(
      turno,
      entregasTurno,
    );
    final entregasPorFora = _countOutsideDeliveries(turno, entregasTurno);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GenericModal(
          title: 'Finalizar turno?',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShiftInfoRow('Restaurante vinculado', turno.restaurante),
              const SizedBox(height: 10),
              _buildShiftInfoRow(
                'Entregas do restaurante',
                '$entregasRestaurante',
              ),
              const SizedBox(height: 10),
              _buildShiftInfoRow('Entregas por fora', '$entregasPorFora'),
              const SizedBox(height: 20),
            ],
          ),
          confirmButtonText: 'Finalizar Turno',
          confirmButtonIcon: Icon(Icons.stop_circle, color: AppColors.corIcone),
          confirmButtonAction: () => _finishShift(turno),
        );
      },
    );
  }

  Future<void> _finishShift(Turno turno) async {
    final turnoId = turno.id;
    if (turnoId == null) return;

    try {
      await FirestoreService().finalizarTurno(turnoId);

      if (!mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Turno finalizado com sucesso!'),
          backgroundColor: AppColors.corSucesso,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao finalizar turno.'),
          backgroundColor: AppColors.corErro,
        ),
      );
    }
  }

  Widget _buildShiftInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  String _resolveCurrentRestaurant({
    required Turno? turnoAtivo,
    required Entrega? entregaRecente,
    required List<String> restaurantes,
  }) {
    if (turnoAtivo != null) return turnoAtivo.restaurante;
    if (_selectedRestaurant != null &&
        restaurantes.contains(_selectedRestaurant)) {
      return _selectedRestaurant!;
    }
    if (entregaRecente != null &&
        restaurantes.contains(entregaRecente.restaurante)) {
      return entregaRecente.restaurante;
    }
    return restaurantes.isEmpty ? 'Nenhum restaurante' : restaurantes.first;
  }

  List<String> _restaurantNames(List<RestaurantModel> restaurantes) {
    return restaurantes
        .map((restaurante) => restaurante.nome.trim())
        .where((nome) => nome.isNotEmpty)
        .toList();
  }

  String? _resolveRestaurantFromList(
    String? selectedRestaurant,
    List<String> restaurants,
  ) {
    if (selectedRestaurant != null &&
        restaurants.contains(selectedRestaurant)) {
      return selectedRestaurant;
    }

    return restaurants.isEmpty ? null : restaurants.first;
  }

  int _countShiftRestaurantDeliveries(Turno turno, List<Entrega> entregas) {
    return entregas
        .where((entrega) => entrega.restaurante == turno.restaurante)
        .length;
  }

  int _countOutsideDeliveries(Turno turno, List<Entrega> entregas) {
    return entregas
        .where((entrega) => entrega.restaurante != turno.restaurante)
        .length;
  }
}

class _DailyActivity {
  final DateTime date;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final double amount;
  final bool isPositive;

  const _DailyActivity({
    required this.date,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isPositive,
  });

  factory _DailyActivity.fromDelivery(Entrega entrega) {
    return _DailyActivity(
      date: entrega.data,
      icon: Icons.location_on,
      color: AppColors.corEntrega,
      title: 'Entrega - ${entrega.restaurante}',
      subtitle: '${entrega.quilometragem} km rodados',
      amount: entrega.valor,
      isPositive: true,
    );
  }

  factory _DailyActivity.fromExpense(Despesa despesa) {
    return _DailyActivity(
      date: despesa.data,
      icon: Icons.receipt_long,
      color: AppColors.corDespesa,
      title: despesa.descricao.isNotEmpty
          ? despesa.descricao
          : despesa.categoria,
      subtitle: despesa.descricao.isNotEmpty ? despesa.categoria : '',
      amount: despesa.valor,
      isPositive: false,
    );
  }
}
