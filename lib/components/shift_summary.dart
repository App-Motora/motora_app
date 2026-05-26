import 'package:flutter/material.dart';
import 'package:motora_app/components/generic_modal.dart';
import 'package:motora_app/constants/app_colors.dart';

class ShiftSummary extends StatelessWidget {
  final String restaurantName;
  final int shiftDeliveryCount;
  final int outsideDeliveryCount;
  final VoidCallback? onFinishShiftPressed;

  const ShiftSummary({
    super.key,
    required this.restaurantName,
    required this.shiftDeliveryCount,
    required this.outsideDeliveryCount,
    this.onFinishShiftPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.corMaterial,
      // borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: () => _openFinishShiftModal(context),
        borderRadius: BorderRadius.circular(15),
        child: Container(
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
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Finalizar turno',
                icon: const Icon(Icons.pause_circle_outline),
                color: AppColors.corIcone,
                onPressed: () => _openFinishShiftModal(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openFinishShiftModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GenericModal(
          title: 'Finalizar turno?',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShiftInfoRow('Restaurante vinculado', restaurantName),
              const SizedBox(height: 10),
              _buildShiftInfoRow(
                'Entregas do restaurante',
                '$shiftDeliveryCount',
              ),
              const SizedBox(height: 10),
              _buildShiftInfoRow('Entregas por fora', '$outsideDeliveryCount'),
              const SizedBox(height: 20),
            ],
          ),
          confirmButtonText: 'Finalizar Turno',
          confirmButtonIcon: Icon(Icons.stop_circle, color: AppColors.corIcone),
          confirmButtonAction: onFinishShiftPressed,
        );
      },
    );
  }

  Widget _buildShiftInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
