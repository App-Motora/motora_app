import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:motora_app/constants/app_colors.dart';
import 'package:motora_app/login_page.dart';

class Menu extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int>? onItemSelected;

  const Menu({super.key, this.selectedIndex = 0, this.onItemSelected});

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
    _MenuItemData(Icons.history, 'Histórico de Atividades', '/home'),
    _MenuItemData(Icons.swap_vert, 'Despesas', null),
    _MenuItemData(Icons.delivery_dining, 'Entregas', '/deliveries_history'),
    _MenuItemData(Icons.analytics, 'Relatórios', null),
    _MenuItemData(Icons.restaurant, 'Restaurantes', null),
  ];

  void _mostrarConfirmacaoSaida(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.corFundoMenu,
          surfaceTintColor: AppColors.corMaterial,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Confirmar Saída',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Você deseja realmente sair da sua conta?',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.corTexto),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.corTexto),
              ),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
              child: const Text(
                'Sair',
                style: TextStyle(
                  color: AppColors.corSair,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.65,
      child: Drawer(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        backgroundColor: AppColors.corFundoMenu,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: AppColors.corPrincipal,
              padding: const EdgeInsets.fromLTRB(20.0, 26.0, 20.0, 18.0),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      color: AppColors.corPrincipal,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fulano',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.corTexto,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 0, thickness: 1, color: AppColors.corBordaInputs),
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
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Center(
                child: InkWell(
                  onTap: () => _mostrarConfirmacaoSaida(context),
                  borderRadius: BorderRadius.circular(14),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.logout, size: 22, color: AppColors.corSair),
                        SizedBox(width: 8),
                        Text(
                          'Sair',
                          style: TextStyle(
                            color: AppColors.corSair,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(bottom: 18.0),
              child: Center(
                child: Text(
                  'Motora App',
                  style: TextStyle(
                    color: AppColors.corTexto,
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
            ? AppColors.corSecundaria.withValues(alpha: 0.16)
            : AppColors.corMaterial,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          dense: true,
          minLeadingWidth: 32,
          splashColor: AppColors.corSecundaria.withValues(alpha: 0.28),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18.0),
          leading: Icon(icon, size: 22, color: AppColors.corTexto),
          title: Text(
            title,
            style: TextStyle(
              color: AppColors.corTexto,
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
            if (widget.onItemSelected != null) {
              widget.onItemSelected?.call(index);
            } else {
              _navigateToRoute(index, context);
            }
          },
        ),
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String title;
  final String? routeName;

  const _MenuItemData(this.icon, this.title, this.routeName);
}

extension on _MenuState {
  void _navigateToRoute(int index, BuildContext context) {
    final route = _items[index].routeName;
    if (route == null) return;

    final currentRoute = ModalRoute.of(context)?.settings.name;
    Navigator.of(context).pop();
    if (currentRoute != route) {
      Navigator.of(context).pushReplacementNamed(route);
    }
  }
}
