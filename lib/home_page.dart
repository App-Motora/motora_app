import 'package:flutter/material.dart';
import 'package:motora_app/components/activity_card.dart';
import 'package:motora_app/components/automatic_delivery_form.dart';
import 'package:motora_app/components/float_button.dart';
import 'package:motora_app/components/generic_modal.dart';
import 'package:motora_app/components/header.dart';
import 'package:motora_app/components/menu.dart';
import 'package:motora_app/home_page_vazia.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List activities = [];
  int _activeMenuIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    bool hasActivities = activities.isNotEmpty;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F2E9),
      drawer: Menu(
        selectedIndex: _activeMenuIndex,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Header(
                  restaurantName: hasActivities
                      ? 'Açaí da Praia'
                      : 'Nenhum restaurante',
                  shiftDuration: hasActivities ? '04h 15m' : '00h 00m',
                  kilometersDriven: hasActivities ? 42.0 : 0.0,
                  receitas: hasActivities ? 36.25 : 0.0,
                  despesas: hasActivities ? 25.00 : 0.0,
                  saldo: hasActivities ? 11.25 : 0.0,
                  onMenuPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),

                Expanded(
                  child: hasActivities
                      ? _buildActivityList()
                      : const HomePageVazia(),
                ),
              ],
            ),

            if (hasActivities)
              Positioned(
                bottom: 30,
                right: 20,
                child: _buildFloatingActionMenu(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList() {
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
          ActivityCard(
            icon: Icons.location_on,
            iconBackgroundColor: const Color(0xFF388E3C),
            time: '14:32',
            title: 'Entrega - Açaí da Praia',
            subtitle: '12.5 km rodados',
            amount: 12.50,
            isPositive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionMenu() {
    return Column(
      children: [
        FloatButton(
          icon: Icons.access_time,
          color: Color(0xFF4FA8FF),
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
                  color: Colors.black,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        FloatButton(
          icon: Icons.swap_vert,
          color: const Color(0xFFFF7E55),
          function: () {},
        ),
        const SizedBox(height: 12),
        FloatButton(
          icon: Icons.delivery_dining,
          color: Color(0xFF388E3C),
          function: () => showDialog(
            context: context,
            builder: (BuildContext context) {
              return AutomaticDeliveryForm();
            },
          ),
        ),
      ],
    );
  }
}
