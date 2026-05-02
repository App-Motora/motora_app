import 'package:flutter/material.dart';
import 'package:motora_app/components/activity_card.dart';
import 'package:motora_app/components/float_button.dart';
import 'package:motora_app/components/menu.dart';

class DeliveriesHistoryPage extends StatefulWidget {
  const DeliveriesHistoryPage({super.key});

  @override
  State<DeliveriesHistoryPage> createState() => _DeliveriesHistoryPageState();
}

class _DeliveriesHistoryPageState extends State<DeliveriesHistoryPage> {
  int _activeMenuIndex = 2;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController txtPesquisa = TextEditingController();

  final List<List<Map<String, dynamic>>> todasEntregas = [
    [
      {
        'time': '14:32',
        'title': 'Entrega - Açaí da Praia',
        'subtitle': '12.5 km rodados',
        'amount': 12.50,
        'isPositive': true,
      },
      {
        'time': '15:34',
        'title': 'Entrega - Açaí da Praia',
        'subtitle': '3 km rodados',
        'amount': 10.30,
        'isPositive': true,
      },
    ],
    [
      {
        'time': '15:34',
        'title': 'Entrega - Açaí da Praia',
        'subtitle': '3 km rodados',
        'amount': 10.30,
        'isPositive': true,
      },
    ],
    [
      {
        'time': '15:34',
        'title': 'Entrega - Açaí da Praia',
        'subtitle': '3 km rodados',
        'amount': 10.30,
        'isPositive': true,
      },
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F2E9),
      drawer: Menu(
        selectedIndex: _activeMenuIndex,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Histórico',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildSearchField(),
                    const SizedBox(height: 24),
                    for (int i = 0; i < todasEntregas.length; i++)
                      if (todasEntregas[i].isNotEmpty) ...[
                        _buildSection(
                          i == 0 ? 'Hoje' : 'Ontem',
                          todasEntregas[i],
                        ),
                        const SizedBox(height: 22),
                      ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8, right: 4),
        child: FloatButton(
          icon: Icons.add,
          color: const Color(0xFF388E3C),
          function: () {},
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildTopBar() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: Color(0xFFF7E18B)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, size: 28),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const Text(
            'Entregas',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: txtPesquisa,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.search, color: Colors.black54),
        hintText: 'Pesquise a entrega',
        hintStyle: const TextStyle(color: Colors.black38),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...activities.map(
          (activity) => ActivityCard(
            icon: Icons.location_on,
            iconBackgroundColor: const Color(0xFF388E3C),
            time: activity['time'] as String,
            title: activity['title'] as String,
            subtitle: activity['subtitle'] as String,
            amount: activity['amount'] as double,
            isPositive: activity['isPositive'] as bool,
          ),
        ),
      ],
    );
  }
}
