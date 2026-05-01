import 'package:flutter/material.dart';
import 'package:motora_app/components/automatic_expense_form.dart';
import 'package:motora_app/components/primary_button.dart';
import 'package:motora_app/components/automatic_delivery_form.dart';

class HomePageVazia extends StatelessWidget {
  const HomePageVazia({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const Text(
            'Você ainda não realizou nenhuma atividade hoje!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Iniciar Turno',
            icon: Icons.history,
            color: const Color(0xFF4FA8FF),
            onPressed: () {},
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Registrar Entrega',
            icon: Icons.delivery_dining,
            color: const Color(0xFF388E3C),
            onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) {
                return AutomaticDeliveryForm();
              },
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Registrar Despesa',
            icon: Icons.swap_vert,
            color: const Color(0xFFFF7E55),
            onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) {
                return const AutomaticExpenseForm();
              },
            ),
          ),
        ],
      ),
    );
  }
}
