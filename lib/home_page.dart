import 'package:flutter/material.dart';
import 'package:motora_app/components/activity_card.dart';
import 'package:motora_app/components/automatic_delivery_form.dart';
import 'package:motora_app/components/float_button.dart';
import 'package:motora_app/components/header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F2E9),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Header(),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 15),
                    child: ListView(
                      physics: BouncingScrollPhysics(),
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
        
            Positioned(bottom: 30, right: 20, child: _buildFloatingActionMenu()),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionMenu() {
    return Column(
      children: [
        FloatButton(
          icon: Icons.access_time, 
          color: Color(0xFF4FA8FF),
          function: () {},
        ),
        SizedBox(height: 12),
        FloatButton(
          icon: Icons.swap_vert, 
          color: Color(0xFFFF7E55),
          function: () {},
        ),
        SizedBox(height: 12),
        FloatButton(
          icon: Icons.delivery_dining, 
          color: Color(0xFF388E3C),
          function: () => showDialog(
            context: context,
            builder: (BuildContext context) {
              return AutomaticDeliveryForm();
            },
          ) ,
        ),
      ],
    );
  }
}
