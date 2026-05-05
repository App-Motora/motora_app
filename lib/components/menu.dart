import 'package:flutter/material.dart';

class Menu extends StatefulWidget {
  final int selectedIndex;
  // final ValueChanged<int>? onItemSelected;

  const Menu({
    super.key,
    this.selectedIndex = 0,
    // this.onItemSelected,
  });

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(covariant Menu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _selectedIndex = widget.selectedIndex;
    }
  }

  final List<_MenuItemData> _items = const [
    _MenuItemData(Icons.swap_vert, 'Despesas'),
    _MenuItemData(Icons.delivery_dining, 'Entregas'),
    _MenuItemData(Icons.analytics, 'Relatórios'),
    _MenuItemData(Icons.history, 'Histórico de Atividades'),
    _MenuItemData(Icons.restaurant, 'Restaurantes'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.65,
      child: Drawer(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        backgroundColor: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFFF7E18B),
              padding: const EdgeInsets.fromLTRB(20.0, 26.0, 20.0, 18.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFFF7E18B),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Fulano',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 0, thickness: 1, color: Color(0xFFE8E8E8)),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 14.0, bottom: 20.0),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return _buildMenuItem(index, item.icon, item.title);
                },
              ),
            ),

            const Divider(height: 0, thickness: 1),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18.0),
              child: Center(
                child: Text(
                  'Motora App',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String title) {
    final selected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 6.0),
      child: Material(
        color: selected
            ? const Color(0xFF4FA8FF).withValues(alpha: 0.16)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          dense: true,
          minLeadingWidth: 32,
          splashColor: const Color(0xFF4FA8FF).withValues(alpha: 0.28),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18.0),
          leading: Icon(icon, size: 22, color: Colors.black87),
          title: Text(
            title,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          selected: selected,
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
            // widget.onItemSelected?.call(index);
          },
        ),
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String title;

  const _MenuItemData(this.icon, this.title);
}
