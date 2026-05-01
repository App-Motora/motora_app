import 'package:flutter/material.dart';
import 'package:motora_app/components/financial_summary_card.dart';

class Header extends StatefulWidget {
  const Header({super.key});

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
        borderRadius: BorderRadius.vertical(),
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
                    items: restaurants.map<DropdownMenuItem<String>>((
                      String value,
                    ) {
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
          Container(
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
          FinancialSummaryCard(receitas: 36.25, despesas: 25.00, saldo: 11.25),
        ],
      ),
    );
  }
}
