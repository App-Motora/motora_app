import 'package:flutter/material.dart';
import 'package:motora_app/components/automatic_expense_form.dart';
import 'package:motora_app/components/generic_modal.dart';
import 'package:motora_app/components/primary_button.dart';
import 'package:motora_app/components/automatic_delivery_form.dart';
import 'package:motora_app/constants/app_colors.dart';

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
              color: AppColors.corTexto,
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Iniciar Turno',
            icon: Icons.history,
            color: AppColors.corSecundaria,
            onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) {
                return GenericModal(
                  title: 'Começar um turno?',
                  content: Column(
                    children: [
                      Text('Restaurante vinculado: Açaí da Praia'),
                      SizedBox(height: 20)
                    ],
                  ),
                  confirmButtonText: 'Iniciar Turno',
                  confirmButtonIcon: Icon(Icons.play_arrow_outlined, color: AppColors.corIcone),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Registrar Entrega',
            icon: Icons.delivery_dining,
            color: AppColors.corEntrega,
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
            color: AppColors.corDespesa,
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
