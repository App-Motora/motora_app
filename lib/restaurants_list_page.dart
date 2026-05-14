import 'package:flutter/material.dart';
import 'package:motora_app/components/menu.dart';
import 'package:motora_app/data/restaurants.dart';

class RestaurantsListPage extends StatefulWidget {
  const RestaurantsListPage({super.key});

  @override
  State<RestaurantsListPage> createState() => _RestaurantsListPageState();
}

class _RestaurantsListPageState extends State<RestaurantsListPage> {
  static const Color _backgroundColor = Color(0xFFF5F2E9);
  static const Color _headerColor = Color(0xFFF7E18B);
  static const int _activeMenuIndex = 4;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _backgroundColor,
      drawer: const Menu(selectedIndex: _activeMenuIndex),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                physics: const BouncingScrollPhysics(),
                children: [
                  const Center(
                    child: Text(
                      'Restaurantes',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  for (final restaurant in availableRestaurants)
                    _RestaurantCard(name: restaurant),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: _headerColor),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, size: 28),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const Text(
            'Restaurantes',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final String name;

  const _RestaurantCard({required this.name});

  static const Color _projectBlue = Color(0xFF4FA8FF);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.10),
        surfaceTintColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _projectBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
