import 'package:flutter/material.dart';
import 'package:motora_app/components/financial_summary_card.dart';

class Header extends StatelessWidget {
  final String restaurantName;
  final String shiftDuration;
  final double kilometersDriven;
  final double receitas;
  final double despesas;
  final double saldo;

  const Header({
    super.key,
    required this.restaurantName,
    required this.shiftDuration,
    required this.kilometersDriven,
    required this.receitas,
    required this.despesas,
    required this.saldo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFFF7E18B),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 15),
      child: Column(
        spacing: 10,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.menu, size: 28),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      restaurantName, 
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Icon(Icons.chevron_right),
                  ],
                ),
              ),
              SizedBox(width: 28),
            ],
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              '$shiftDuration de turno | ${kilometersDriven.toStringAsFixed(0)} km rodados', 
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
          FinancialSummaryCard(
            receitas: receitas, 
            despesas: despesas, 
            saldo: saldo,       
          ),
        ],
      ),
    );
  }
}