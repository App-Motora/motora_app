import 'package:flutter/material.dart';

class ActivityCard extends StatelessWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final String time;
  final String title;
  final String? subtitle;
  final double amount;
  final bool isPositive;

  const ActivityCard({
    Key? key,
    required this.icon,
    required this.iconBackgroundColor,
    this.iconColor = Colors.white,
    required this.time,
    required this.title,
    this.subtitle,
    required this.amount,
    required this.isPositive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícone
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          SizedBox(width: 16),
          // Textos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
          // Valor
          Text(
            '${isPositive ? '+' : '-'}R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isPositive ? Color(0xFF4CAF50) : Color(0xFFFF7E55),
            ),
          ),
        ],
      ),
    );
  }
}
