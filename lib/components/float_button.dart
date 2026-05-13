import 'package:flutter/material.dart';
import 'package:motora_app/constants/app_colors.dart';

class FloatButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback function;

  const FloatButton({
    super.key,
    required this.icon,
    required this.color,
    required this.function,
  });

@override
  Widget build (BuildContext context) {
    return Container(
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.corSombra,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.corIconeClaro),
        onPressed: () => function(),
      ),
    );
  }
}