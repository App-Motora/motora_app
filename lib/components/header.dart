import 'package:flutter/material.dart';
import 'package:motora_app/components/financial_summary_card.dart';
import 'package:motora_app/components/shift_summary.dart';
import 'package:motora_app/constants/app_colors.dart';

class Header extends StatefulWidget {
  final String restaurantName;
  final String shiftDuration;
  final double kilometersDriven;
  final double receitas;
  final double despesas;
  final double saldo;
  final VoidCallback? onMenuPressed;

  const Header({
    super.key,
    required this.restaurantName,
    required this.shiftDuration,
    required this.kilometersDriven,
    required this.receitas,
    required this.despesas,
    required this.saldo,
    this.onMenuPressed,
  });

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  String restauranteSelecionado = 'Açaí da Praia';

  final List<String> restaurantes = [
    'Açaí da Praia',
    'Pizzaria Central',
    'Hambúrguer do Zé',
    'Sushi Express Grande',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.corPrincipal),
      padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 15),
      child: Column(
        spacing: 10,
        children: [
          SizedBox(
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.menu, size: 30),
                    onPressed: widget.onMenuPressed,
                  ),
                ),
                Center(
                  child: DropdownMenu<String>(
                    inputDecorationTheme: InputDecorationThemeData(
                      filled: true,
                      fillColor: AppColors.corInputs.withValues(alpha: 0.5),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    initialSelection: restauranteSelecionado,
                    dropdownMenuEntries: restaurantes.map((String value) {
                      final bool isSelected =
                        value == restauranteSelecionado;
                              
                      return DropdownMenuEntry<String>(
                        value: value,
                        label: value,
                        style: AppColors.dropdownMenuItemStyle(isSelected),
                      );
                    }).toList(),
                    onSelected: (String? newValue) {
                      if (newValue == null) return;
                              
                      setState(() {
                        restauranteSelecionado = newValue;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          ShiftSummary(
            shiftDuration: widget.shiftDuration,
            kilometersDriven: widget.kilometersDriven,
            receitas: widget.receitas,
            despesas: widget.despesas,
            saldo: widget.saldo,
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
