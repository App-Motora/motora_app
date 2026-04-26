import 'package:flutter/material.dart';
import 'package:motora_app/components/activity_card.dart';
import 'package:motora_app/components/float_button.dart';
import 'package:motora_app/components/header.dart';
import 'package:motora_app/home_page_vazia.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List activities = [];

  @override
  Widget build(BuildContext context) {
    bool hasActivities = activities.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2E9),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const Header(
                  restaurantName: 'Açaí da Praia',
                  shiftDuration: '04h 15m',
                  kilometersDriven: 42.0,
                  receitas: 36.25,
                  despesas: 25.00,
                  saldo: 11.25,
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
          color: const Color(0xFF4FA8FF),
          function: () {},
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
          color: const Color(0xFF388E3C),
          function: () {},
        ),
      ],
    );
  }
}
