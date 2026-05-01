import 'package:flutter/material.dart';
import 'package:motora_app/components/financial_summary_card.dart';
import 'package:motora_app/components/shift_summary.dart';

class Header extends StatefulWidget {
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
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  String selectedRestaurant = 'Açaí da Praia';

  final List<String> restaurants = [
    'Açaí da Praia',
    'Pizzaria Central',
    'Hambúrguer do Zé',
    'Sushi Express Grande',
  ];

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
              Icon(Icons.menu, size: 30),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedRestaurant,
                    icon: Icon(Icons.chevron_right, color: Colors.black),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 14,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedRestaurant = newValue!;
                      });
                    },
                    dropdownColor: Colors.white,
                    alignment: Alignment.center,
                    items: restaurants.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(width: 28),
            ],
          ),
          ShiftSummary(
            shiftDuration: widget.shiftDuration, 
            kilometersDriven: widget.kilometersDriven, 
            receitas: widget.receitas, 
            despesas: widget.despesas, 
            saldo: widget.saldo
          ),
          FinancialSummaryCard(
            receitas: widget.receitas,
            despesas: widget.despesas,
            saldo: widget.saldo,
          ),
        ],
      ),
    );
  }
}
