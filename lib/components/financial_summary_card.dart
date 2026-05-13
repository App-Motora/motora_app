import 'package:flutter/material.dart';
import 'package:motora_app/constants/app_colors.dart';

class FinancialSummaryCard extends StatelessWidget {
  final double receitas;
  final double despesas;
  final double saldo;

  const FinancialSummaryCard({
    super.key,
    required this.receitas,
    required this.despesas,
    required this.saldo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      decoration: BoxDecoration(
        color: AppColors.corFundoMenu,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.corSombra.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildColumn('Receitas', receitas, AppColors.corEntrega ),
          _buildColumn('Despesas', despesas, AppColors.corDespesa),
          _buildColumn('Saldo', saldo, AppColors.corSecundaria),
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
            color: AppColors.corTexto,
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
