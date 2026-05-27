import 'package:flutter/material.dart';
import 'package:motora_app/components/financial_summary_card.dart';
import 'package:motora_app/components/shift_summary.dart';
import 'package:motora_app/constants/app_colors.dart';

class Header extends StatelessWidget {
  final String selectedRestaurant;
  final List<String> restaurants;
  final bool hasActiveShift;
  final DateTime? shiftStartedAt;
  final int shiftDeliveryCount;
  final int outsideDeliveryCount;
  final double shiftTotalKm;
  final double shiftRevenue;
  final double shiftExpenses;
  final double receitas;
  final double despesas;
  final double saldo;
  final VoidCallback? onMenuPressed;
  final Future<void> Function()? onFinishShiftPressed;
  final ValueChanged<String>? onRestaurantSelected;

  const Header({
    super.key,
    required this.selectedRestaurant,
    required this.restaurants,
    required this.hasActiveShift,
    this.shiftStartedAt,
    required this.shiftDeliveryCount,
    required this.outsideDeliveryCount,
    required this.shiftTotalKm,
    required this.shiftRevenue,
    required this.shiftExpenses,
    required this.receitas,
    required this.despesas,
    required this.saldo,
    this.onMenuPressed,
    this.onFinishShiftPressed,
    this.onRestaurantSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: AppColors.corPrincipal),
      padding: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 15),
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
                    onPressed: onMenuPressed,
                  ),
                ),
                Center(child: _buildRestaurantSelector()),
              ],
            ),
          ),
          if (hasActiveShift && shiftStartedAt != null)
            ShiftSummary(
              restaurantName: selectedRestaurant,
              startedAt: shiftStartedAt!,
              shiftDeliveryCount: shiftDeliveryCount,
              outsideDeliveryCount: outsideDeliveryCount,
              totalKm: shiftTotalKm,
              revenue: shiftRevenue,
              expenses: shiftExpenses,
              onFinishShiftPressed: onFinishShiftPressed,
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

  Widget _buildRestaurantSelector() {
    final restaurantEntries = restaurants.isEmpty
        ? [selectedRestaurant]
        : restaurants;
    final String? initialRestaurant;

    if (restaurants.isEmpty || restaurants.contains(selectedRestaurant)) {
      initialRestaurant = selectedRestaurant;
    } else {
      initialRestaurant = null;
    }

    if (hasActiveShift) {
      return Container(
        constraints: const BoxConstraints(maxWidth: 260),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.corInputs.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          selectedRestaurant,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.corTexto,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return DropdownMenu<String>(
      key: ValueKey(selectedRestaurant),
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
      initialSelection: initialRestaurant,
      dropdownMenuEntries: restaurantEntries.map((value) {
        final bool isSelected = value == selectedRestaurant;

        return DropdownMenuEntry<String>(
          value: value,
          label: value,
          style: AppColors.dropdownMenuItemStyle(isSelected),
        );
      }).toList(),
      onSelected: (value) {
        if (value == null) return;
        onRestaurantSelected?.call(value);
      },
    );
  }
}
