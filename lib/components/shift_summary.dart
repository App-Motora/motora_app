import 'package:flutter/material.dart';
import 'package:motora_app/components/generic_modal.dart';

class ShiftSummary extends StatelessWidget {
  const ShiftSummary({super.key});

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
                  Text('Tempo de turno: 04h 15m'),
                  Text('Quilômetros rodados: 42km'),
                  Text('Restaurante vinculado: Açaí da Praia'),
                  SizedBox(height: 20)
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
            '04h 15m de turno | 42 km rodados',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ),
      ),
    );
  }
}