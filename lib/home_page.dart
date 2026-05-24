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
import 'package:motora_app/services/firestore_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final int _activeMenuIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.corFundo,
      drawer: Menu(selectedIndex: _activeMenuIndex),
      body: SafeArea(
        child: StreamBuilder<List<Entrega>>(
          stream: FirestoreService().buscarEntregasDoDia(),
          builder: (context, entregasSnapshot) {
            return StreamBuilder<List<Despesa>>(
              stream: FirestoreService().buscarDespesasDoDia(),
              builder: (context, despesasSnapshot) {
                final isLoading =
                    entregasSnapshot.connectionState ==
                        ConnectionState.waiting ||
                    despesasSnapshot.connectionState == ConnectionState.waiting;
                final hasError =
                    entregasSnapshot.hasError || despesasSnapshot.hasError;
                final entregas = entregasSnapshot.data ?? [];
                final despesas = despesasSnapshot.data ?? [];
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
                final kilometersDriven = entregas.fold<double>(
                  0,
                  (total, entrega) => total + entrega.quilometragem,
                );

                return Stack(
                  children: [
                    Column(
                      children: [
                        Header(
                          restaurantName: hasActivities
                              ? 'Açaí da Praia'
                              : 'Nenhum restaurante',
                          shiftDuration: hasActivities ? '04h 15m' : '00h 00m',
                          kilometersDriven: kilometersDriven,
                          receitas: totalEntregas,
                          despesas: totalDespesas,
                          saldo: saldo,
                          onMenuPressed: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                        ),
                        Expanded(
                          child: _buildBody(
                            isLoading: isLoading,
                            hasError: hasError,
                            hasActivities: hasActivities,
                            activities: activities,
                          ),
                        ),
                      ],
                    ),
                    if (hasActivities && !isLoading && !hasError)
                      Positioned(
                        bottom: 30,
                        right: 20,
                        child: _buildFloatingActionMenu(),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody({
    required bool isLoading,
    required bool hasError,
    required bool hasActivities,
    required List<_DailyActivity> activities,
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
      return const HomePageVazia();
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

  Widget _buildFloatingActionMenu() {
    return Column(
      children: [
        FloatButton(
          icon: Icons.access_time,
          color: AppColors.corSecundaria,
          function: () => showDialog(
            context: context,
            builder: (BuildContext context) {
              return GenericModal(
                title: 'Começar um turno?',
                content: Column(
                  children: [
                    Text('Restaurante vinculado: Açaí da Praia'),
                    SizedBox(height: 20),
                  ],
                ),
                confirmButtonText: 'Iniciar Turno',
                confirmButtonIcon: Icon(
                  Icons.play_arrow_outlined,
                  color: AppColors.corIcone,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
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
              return AutomaticDeliveryForm();
            },
          ),
        ),
      ],
    );
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
      title: despesa.categoria,
      subtitle: despesa.descricao,
      amount: despesa.valor,
      isPositive: false,
    );
  }
}
