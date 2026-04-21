import 'package:flutter/material.dart';
import 'package:motora_app/components/activity_card.dart';
import 'package:motora_app/components/financial_summary_card.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Color(0xFFF5F2E9),
      body: Stack(
        children: [
          Column(
            children: [
              // 1. Header Amarelo
              _buildHeader(),

              // 3. Lista de Atividades
              Expanded(
                child: Padding(
                  padding:EdgeInsets.symmetric(horizontal: 20),
                  child: ListView(
                    physics:BouncingScrollPhysics(),
                    children: [
                    Center(
                        child: Text(
                          'Atividades de Hoje',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                      ),
                    SizedBox(height: 20),

                      // Usando o componente ActivityTile que criamos
                    ActivityCard(
                        icon: Icons.location_on,
                        iconBackgroundColor: Color(0xFF388E3C),
                        time: '14:32',
                        title: 'Entrega - Açaí da Praia',
                        subtitle: '12.5 km rodados',
                        amount: 12.50,
                        isPositive: true,
                      ),

                    ActivityCard(
                        icon: Icons.local_gas_station,
                        iconBackgroundColor: Color(0xFFFF7E55),
                        time: '16:46',
                        title: 'Gasolina',
                        amount: 25.00,
                        isPositive: false,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 5. Botões Flutuantes (Customizados conforme o print)
          Positioned(bottom: 30, right: 20, child: _buildFloatingActionMenu()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration:BoxDecoration(
        color: Color(0xFFF7E18B), // Amarelo do Figma
        borderRadius: BorderRadius.vertical(),
      ),
      padding:EdgeInsets.only(top: 60, left: 20, right: 20),
      child: Column(
        spacing: 10,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            Icon(Icons.menu, size: 28),
              Container(
                padding:EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children:[
                    Text(
                      'Açaí da Praia',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Icon(Icons.chevron_right),
                  ],
                ),
              ),
            SizedBox(width: 28), // Equilíbrio visual
            ],
          ),
          Container(
            padding:EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(15),
            ),
            child:Text(
              '04h 15m de turno | 42 km rodados',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
          FinancialSummaryCard(receitas: 36.25, despesas: 25.00, saldo: 11.25),
        ],
      ),
    );
  }

  Widget _buildFloatingActionMenu() {
    return Column(
      children: [
        _miniFob(Icons.access_time,Color(0xFF4FA8FF)),
      SizedBox(height: 12),
        _miniFob(Icons.swap_vert,Color(0xFFFF7E55)),
      SizedBox(height: 12),
        _miniFob(Icons.delivery_dining,Color(0xFF388E3C)),
      ],
    );
  }

  Widget _miniFob(IconData icon, Color color) {
    return Container(
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}
