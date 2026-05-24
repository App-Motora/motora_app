import 'package:flutter/material.dart';
import 'package:motora_app/components/automatic_delivery_form.dart';
import 'package:motora_app/components/automatic_expense_form.dart';
import 'package:motora_app/components/primary_button.dart';
import 'package:motora_app/constants/app_colors.dart';

class HomePageVazia extends StatelessWidget {
  final String? initialRestaurant;
  final bool hasActiveShift;
  final VoidCallback? onStartShiftPressed;

  const HomePageVazia({
    super.key,
    this.initialRestaurant,
    this.hasActiveShift = false,
    this.onStartShiftPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
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
            if (!hasActiveShift) ...[
              PrimaryButton(
                label: 'Iniciar Turno',
                icon: Icons.history,
                color: AppColors.corSecundaria,
                onPressed: onStartShiftPressed ?? () {},
              ),
              const SizedBox(height: 20),
            ],
            PrimaryButton(
              label: 'Registrar Entrega',
              icon: Icons.delivery_dining,
              color: AppColors.corEntrega,
              onPressed: () => showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AutomaticDeliveryForm(
                    initialRestaurant: initialRestaurant,
                  );
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
      ),
    );
  }
}
