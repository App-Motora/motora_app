import 'package:flutter/material.dart';
import 'package:motora_app/components/financial_summary_card.dart';
import 'package:motora_app/constants/app_colors.dart';
import 'package:motora_app/data/restaurants.dart';

class Header extends StatelessWidget {
  final String selectedRestaurant;
  final bool hasActiveShift;
  final int shiftDeliveryCount;
  final double receitas;
  final double despesas;
  final double saldo;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onFinishShiftPressed;
  final ValueChanged<String>? onRestaurantSelected;

  const Header({
    super.key,
    required this.selectedRestaurant,
    required this.hasActiveShift,
    required this.shiftDeliveryCount,
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
          if (hasActiveShift) _buildShiftInfo(),
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

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 260),
      child: DropdownButtonFormField<String>(
        key: ValueKey(selectedRestaurant),
        initialValue: availableRestaurants.contains(selectedRestaurant)
            ? selectedRestaurant
            : null,
        isExpanded: true,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.corInputs.withValues(alpha: 0.5),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
        items: availableRestaurants.map((value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: (value) {
          if (value == null) return;
          onRestaurantSelected?.call(value);
        },
      ),
    );
  }

  Widget _buildShiftInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.corInputs.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$shiftDeliveryCount ${shiftDeliveryCount == 1 ? 'entrega' : 'entregas'} no turno',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
          const SizedBox(width: 8),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Finalizar turno',
            icon: const Icon(Icons.stop_circle_outlined),
            color: AppColors.corIcone,
            onPressed: onFinishShiftPressed,
          ),
        ],
      ),
    );
  }
}
