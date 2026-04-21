import 'package:flutter/material.dart';

class FinancialSummaryCard extends StatelessWidget {
  final double receitas;
  final double despesas;
  final double saldo;

  const FinancialSummaryCard({
    Key? key,
    required this.receitas,
    required this.despesas,
    required this.saldo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildColumn(
            'Receitas',
            receitas,
            Color(0xFF4FA8FF),
          ), // Azul do print
          _buildColumn(
            'Despesas',
            despesas,
            Color(0xFFFF7E55),
          ), // Laranja/Vermelho
          _buildColumn('Saldo', saldo, Color(0xFF4CAF50)), // Verde
        ],
      ),
    );
  }

  Widget _buildColumn(String title, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    );
  }
}
