import 'package:flutter/material.dart';
import 'package:motora_app/components/generic_modal.dart';

class ShiftSummary extends StatelessWidget {
  final String shiftDuration;
  final double kilometersDriven;
  final double receitas;
  final double despesas;
  final double saldo;

  const ShiftSummary({
    super.key,
    required this.shiftDuration,
    required this.kilometersDriven,
    required this.receitas,
    required this.despesas,
    required this.saldo,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showDialog(
          context: context,
          builder: (BuildContext context) {
            return GenericModal(
              title: 'Informações do Turno',
              content: Column(
                children: [
                  Text('Tempo de turno: $shiftDuration'),
                  Text(
                    'Quilômetros rodados: ${kilometersDriven.toStringAsFixed(0)}km',
                  ),
                  Text('Restaurante vinculado: Açaí da Praia'),
                  SizedBox(height: 20),
                ],
              ),
              confirmButtonText: 'Finalizar Turno',
              confirmButtonIcon: Icon(Icons.pause, color: Colors.black),
            );
          },
        ),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            '$shiftDuration de turno | ${kilometersDriven.toStringAsFixed(0)} km rodados',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ),
      ),
    );
  }
}