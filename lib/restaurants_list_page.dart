import 'package:flutter/material.dart';
import 'package:motora_app/components/float_button.dart';
import 'package:motora_app/components/menu.dart';
import 'package:motora_app/components/restaurant_form.dart';
import 'package:motora_app/constants/app_colors.dart';
import 'package:motora_app/models/delivery_model.dart';
import 'package:motora_app/models/restaurant_model.dart';
import 'package:motora_app/services/firestore_service.dart';

class RestaurantsListPage extends StatefulWidget {
  const RestaurantsListPage({super.key});

  @override
  State<RestaurantsListPage> createState() => _RestaurantsListPageState();
}

class _RestaurantsListPageState extends State<RestaurantsListPage> {
  static const Color _backgroundColor = AppColors.corFundo;
  static const Color _headerColor = AppColors.corPrincipal;
  static const int _activeMenuIndex = 4;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirestoreService _firestoreService = FirestoreService();

  late final Stream<List<RestaurantModel>> _restaurantsStream;
  late final Stream<List<Entrega>> _deliveriesStream;

  @override
  void initState() {
    super.initState();
    _restaurantsStream = _firestoreService.buscarRestaurantes();
    _deliveriesStream = _firestoreService.buscarEntregas();
  }

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
              child: StreamBuilder<List<RestaurantModel>>(
                stream: _restaurantsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.corSecundaria,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Erro ao carregar restaurantes.'),
                    );
                  }

                  final restaurants = snapshot.data ?? [];

                  return StreamBuilder<List<Entrega>>(
                    stream: _deliveriesStream,
                    builder: (context, deliveriesSnapshot) {
                      final tripsByRestaurant = _countTripsByRestaurant(
                        deliveriesSnapshot.data ?? [],
                      );

                      return _buildRestaurantsList(
                        restaurants,
                        tripsByRestaurant,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8, right: 4),
        child: FloatButton(
          icon: Icons.add,
          color: AppColors.corSecundaria,
          function: _openCreateRestaurantModal,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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

  Widget _buildRestaurantsList(
    List<RestaurantModel> restaurants,
    Map<String, int> tripsByRestaurant,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 92),
      physics: const BouncingScrollPhysics(),
      children: [
        const Center(
          child: Text(
            'Restaurantes Cadastrados',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),
        if (restaurants.isEmpty)
          const _EmptyRestaurantsState()
        else
          for (final restaurant in restaurants)
            _RestaurantCard(
              restaurant: restaurant,
              tripsCount:
                  tripsByRestaurant[_normalizeName(restaurant.nome)] ?? 0,
              onTap: () => _openRestaurantDetails(restaurant),
            ),
      ],
    );
  }

  Map<String, int> _countTripsByRestaurant(List<Entrega> deliveries) {
    final tripsByRestaurant = <String, int>{};

    for (final delivery in deliveries) {
      final restaurantName = _normalizeName(delivery.restaurante);
      tripsByRestaurant[restaurantName] =
          (tripsByRestaurant[restaurantName] ?? 0) + 1;
    }

    return tripsByRestaurant;
  }

  void _openCreateRestaurantModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) => const RestaurantForm(),
    );
  }

  void _openRestaurantDetails(RestaurantModel restaurant) {
    final restaurantId = restaurant.id;
    if (restaurantId == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantDetailsPage(
          restaurantId: restaurantId,
          initialRestaurant: restaurant,
        ),
      ),
    );
  }

  static String _normalizeName(String value) {
    return value.trim().toLowerCase();
  }
}

class _RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;
  final int tripsCount;
  final VoidCallback onTap;

  const _RestaurantCard({
    required this.restaurant,
    required this.tripsCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.corFundoMenu,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        elevation: 1,
        shadowColor: AppColors.corSombra,
        surfaceTintColor: AppColors.corMaterial,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.corSecundaria,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: AppColors.corIconeClaro,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.corTexto,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        restaurant.perfilPagamento.resumo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.corTexto.withValues(alpha: 0.65),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _TripsBadge(tripsCount: tripsCount),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TripsBadge extends StatelessWidget {
  final int tripsCount;

  const _TripsBadge({required this.tripsCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 42),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.corPrincipal,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            tripsCount.toString(),
            style: const TextStyle(
              color: AppColors.corTexto,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            tripsCount == 1 ? 'viagem' : 'viagens',
            style: TextStyle(
              color: AppColors.corTexto.withValues(alpha: 0.65),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRestaurantsState extends StatelessWidget {
  const _EmptyRestaurantsState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.corSecundaria.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant,
              color: AppColors.corSecundaria,
              size: 42,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhum restaurante cadastrado',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.corTexto,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use o botao de adicionar para criar o primeiro restaurante.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.corTexto.withValues(alpha: 0.65),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class RestaurantDetailsPage extends StatefulWidget {
  final String restaurantId;
  final RestaurantModel initialRestaurant;

  const RestaurantDetailsPage({
    super.key,
    required this.restaurantId,
    required this.initialRestaurant,
  });

  @override
  State<RestaurantDetailsPage> createState() => _RestaurantDetailsPageState();
}

class _RestaurantDetailsPageState extends State<RestaurantDetailsPage> {
  static const Color _backgroundColor = AppColors.corFundo;
  static const Color _primaryYellow = AppColors.corPrincipal;
  static const Color _textColor = AppColors.corTexto;

  final FirestoreService _firestoreService = FirestoreService();
  final Color _dividerColor = AppColors.corSombra;

  late final Stream<RestaurantModel?> _restaurantStream;
  late final Stream<List<Entrega>> _deliveriesStream;

  @override
  void initState() {
    super.initState();
    _restaurantStream = _firestoreService.buscarRestaurantePorId(
      widget.restaurantId,
    );
    _deliveriesStream = _firestoreService.buscarEntregas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: StreamBuilder<RestaurantModel?>(
          stream: _restaurantStream,
          initialData: widget.initialRestaurant,
          builder: (context, restaurantSnapshot) {
            if (restaurantSnapshot.hasError) {
              return const Center(child: Text('Erro ao carregar restaurante.'));
            }

            final restaurant = restaurantSnapshot.data;
            if (restaurant == null) {
              return _buildDeletedState();
            }

            return StreamBuilder<List<Entrega>>(
              stream: _deliveriesStream,
              builder: (context, deliveriesSnapshot) {
                final tripsCount = _countTrips(
                  restaurant.nome,
                  deliveriesSnapshot.data ?? [],
                );

                return Column(
                  children: [
                    _buildHeader(restaurant, tripsCount),
                    Expanded(child: _buildOptions(restaurant)),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(RestaurantModel restaurant, int tripsCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 34),
      decoration: const BoxDecoration(color: _primaryYellow),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new, color: _textColor),
              ),
              const Expanded(
                child: Text(
                  'Restaurante',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 18),
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.corFundoMenu,
            child: const Icon(
              Icons.restaurant,
              color: AppColors.corSecundaria,
              size: 54,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            restaurant.nome,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _textColor,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            tripsCount == 1
                ? '1 viagem realizada'
                : '$tripsCount viagens realizadas',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textColor.withValues(alpha: 0.75),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions(RestaurantModel restaurant) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.corFundoMenu),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          _buildPaymentSummary(restaurant),
          const SizedBox(height: 10),
          _buildOptionTile(
            icon: Icons.storefront_outlined,
            title: 'Editar informacoes do restaurante',
            onTap: () => _openRestaurantInfoModal(restaurant),
          ),
          _buildOptionTile(
            icon: Icons.payments_outlined,
            title: 'Editar perfil de pagamento',
            onTap: () => _openPaymentProfileModal(restaurant),
          ),
          _buildOptionTile(
            icon: Icons.delete_outline,
            title: 'Excluir restaurante',
            iconColor: AppColors.corErro,
            textColor: AppColors.corErro,
            showTrailing: false,
            onTap: () => _confirmDeleteRestaurant(restaurant),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(RestaurantModel restaurant) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.corFundo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.corBordaInputs),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.corSecundaria,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: AppColors.corTexto,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Perfil de pagamento',
                  style: TextStyle(
                    color: AppColors.corTexto,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  restaurant.perfilPagamento.resumo,
                  style: TextStyle(
                    color: AppColors.corTexto.withValues(alpha: 0.7),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = _textColor,
    Color textColor = _textColor,
    bool showTrailing = true,
  }) {
    return Column(
      children: [
        ListTile(
          minLeadingWidth: 32,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          leading: Icon(icon, color: iconColor, size: 25),
          title: Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: showTrailing
              ? Icon(
                  Icons.chevron_right,
                  color: AppColors.corTexto.withValues(alpha: 0.75),
                )
              : null,
          onTap: onTap,
        ),
        Divider(height: 1, color: _dividerColor),
      ],
    );
  }

  Widget _buildDeletedState() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: const BoxDecoration(color: _primaryYellow),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new, color: _textColor),
              ),
              const Expanded(
                child: Text(
                  'Restaurante',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
        const Expanded(
          child: Center(child: Text('Restaurante nao encontrado.')),
        ),
      ],
    );
  }

  void _openRestaurantInfoModal(RestaurantModel restaurant) {
    showDialog(
      context: context,
      builder: (BuildContext context) => RestaurantForm(
        restaurant: restaurant,
        mode: RestaurantFormMode.information,
      ),
    );
  }

  void _openPaymentProfileModal(RestaurantModel restaurant) {
    showDialog(
      context: context,
      builder: (BuildContext context) => RestaurantForm(
        restaurant: restaurant,
        mode: RestaurantFormMode.payment,
      ),
    );
  }

  Future<void> _confirmDeleteRestaurant(RestaurantModel restaurant) async {
    final restaurantId = restaurant.id;

    if (restaurantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nao foi possivel identificar este restaurante.'),
          backgroundColor: AppColors.corErro,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.corFundo,
          title: const Text('Excluir restaurante?'),
          content: Text(
            '${restaurant.nome} sera removido da sua lista de restaurantes.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.corTexto),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Excluir',
                style: TextStyle(color: AppColors.corExcluir),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await _firestoreService.excluirRestaurante(restaurantId);

      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Restaurante excluido com sucesso!'),
          backgroundColor: AppColors.corSucesso,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao excluir restaurante.'),
          backgroundColor: AppColors.corErro,
        ),
      );
    }
  }

  int _countTrips(String restaurantName, List<Entrega> deliveries) {
    final normalizedRestaurantName = _normalizeName(restaurantName);
    return deliveries
        .where(
          (delivery) =>
              _normalizeName(delivery.restaurante) == normalizedRestaurantName,
        )
        .length;
  }

  String _normalizeName(String value) {
    return value.trim().toLowerCase();
  }
}
