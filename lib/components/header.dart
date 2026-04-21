import 'package:flutter/material.dart';
import 'package:motora_app/components/financial_summary_card.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFFF7E18B),
        borderRadius: BorderRadius.vertical(),
      ),
      padding: EdgeInsets.only(top: 60, left: 20, right: 20),
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
                      'Açaí da Praia',
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
              '04h 15m de turno | 42 km rodados',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
          FinancialSummaryCard(receitas: 36.25, despesas: 25.00, saldo: 11.25),
        ],
      ),
    );
  }
}