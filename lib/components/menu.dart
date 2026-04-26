import 'package:flutter/material.dart';

class Menu extends StatefulWidget
{
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.65,
      child: Drawer(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Column(
          children: [
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Fulano",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "fulano@email.com",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(Icons.swap_vert, "Despesas"),
                  _buildMenuItem(Icons.delivery_dining, "Entregas"),
                  _buildMenuItem(Icons.analytics, "Relatórios"),
                  _buildMenuItem(Icons.history, "Histórico de Atividades"),
                  _buildMenuItem(Icons.restaurant, "Restaurantes"),
                ],
              ),
            ),

            Divider(),
            ListTile(
              title: Text(
                "Sair",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                // Lógica de logout
              },
            ),
            SizedBox(height: 7),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, size: 18),
      title: Text(title),
      trailing: Icon(Icons.chevron_right),
      onTap: () {
        // Navegação aqui
      },
    );
  }
}