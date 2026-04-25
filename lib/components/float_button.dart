import 'package:flutter/material.dart';

class FloatButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback function;

  const FloatButton({
    Key? key,
    required this.icon,
    required this.color,
    required this.function,
  }) : super(key: key);

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
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: () => function(),
      ),
    );
  }
}