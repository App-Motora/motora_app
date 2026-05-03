import 'package:flutter/material.dart';
import 'package:motora_app/components/activity_card.dart';
import 'package:motora_app/components/float_button.dart';
import 'package:motora_app/components/menu.dart';
import 'package:motora_app/components/manual_delivery_form.dart';
import 'package:motora_app/models/delivery_model.dart';
import 'package:motora_app/services/firestore_service.dart';
import 'package:intl/intl.dart';

class DeliveriesHistoryPage extends StatefulWidget {
  const DeliveriesHistoryPage({super.key});

  @override
  State<DeliveriesHistoryPage> createState() => _DeliveriesHistoryPageState();
}

class _DeliveriesHistoryPageState extends State<DeliveriesHistoryPage> {
  int _activeMenuIndex = 2;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController txtPesquisa = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F2E9),
      drawer: Menu(selectedIndex: _activeMenuIndex),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: StreamBuilder<List<Entrega>>(
                stream: FirestoreService().buscarEntregas(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF388E3C)));
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Erro ao carregar o histórico.'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('Nenhuma entrega registrada ainda.', style: TextStyle(fontSize: 16)),
                    );
                  }
                  final entregas = snapshot.data!;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Histórico',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 18),
                        _buildSearchField(),
                        const SizedBox(height: 24),
                        
                        _buildSectionReal('Todas as Entregas', entregas),
                        const SizedBox(height: 22),
                      ],
                    ),
                  );
                },
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
          function: () => showDialog(
            context: context,
            builder: (BuildContext context) {
              return ManualDeliveryForm();
            },
          ),
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

  Widget _buildSectionReal(String title, List<Entrega> entregas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...entregas.map((entrega) {
          final horaFormatada = DateFormat('HH:mm').format(entrega.data);

          return ActivityCard(
            icon: Icons.location_on,
            iconBackgroundColor: const Color(0xFF388E3C),
            time: horaFormatada,
            title: 'Entrega - ${entrega.restaurante}',
            subtitle: '${entrega.quilometragem} km rodados',
            amount: entrega.valor,
            isPositive: true,
          );
        }), 
      ],
    );
  }
}
