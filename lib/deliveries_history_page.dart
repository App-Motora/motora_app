import 'package:flutter/material.dart';
import 'package:motora_app/components/activity_card.dart';
import 'package:motora_app/components/float_button.dart';
import 'package:motora_app/components/menu.dart';
import 'package:motora_app/components/manual_delivery_form.dart';
import 'package:motora_app/models/delivery_model.dart';
import 'package:motora_app/services/firestore_service.dart';
import 'package:intl/intl.dart';

enum FiltroDatas { hoje, ontem, estaSemana, esteMes }

extension FiltroDatasLabel on FiltroDatas {
  String get label {
    switch (this) {
      case FiltroDatas.hoje:
        return 'Hoje';
      case FiltroDatas.ontem:
        return 'Ontem';
      case FiltroDatas.estaSemana:
        return 'Esta semana';
      case FiltroDatas.esteMes:
        return 'Este mês';
    }
  }

  IconData get icon {
    switch (this) {
      case FiltroDatas.hoje:
        return Icons.today;
      case FiltroDatas.ontem:
        return Icons.history;
      case FiltroDatas.estaSemana:
        return Icons.date_range;
      case FiltroDatas.esteMes:
        return Icons.calendar_month;
    }
  }

  DateTimeRange get intervalo {
    final hoje = DateTime.now();
    final inicioHoje = DateTime(hoje.year, hoje.month, hoje.day);
    final fimHoje = DateTime(hoje.year, hoje.month, hoje.day, 23, 59, 59);

    switch (this) {
      case FiltroDatas.hoje:
        return DateTimeRange(start: inicioHoje, end: fimHoje);

      case FiltroDatas.ontem:
        final ontem = inicioHoje.subtract(const Duration(days: 1));
        return DateTimeRange(
          start: ontem,
          end: DateTime(ontem.year, ontem.month, ontem.day, 23, 59, 59),
        );

      case FiltroDatas.estaSemana:
        final diasDesdeSegunda = hoje.weekday - 1;
        final segundaFeira = inicioHoje.subtract(
          Duration(days: diasDesdeSegunda),
        );
        return DateTimeRange(start: segundaFeira, end: fimHoje);

      case FiltroDatas.esteMes:
        return DateTimeRange(
          start: DateTime(hoje.year, hoje.month, 1),
          end: fimHoje,
        );
    }
  }
}

class DeliveriesHistoryPage extends StatefulWidget {
  const DeliveriesHistoryPage({super.key});

  @override
  State<DeliveriesHistoryPage> createState() => _DeliveriesHistoryPageState();
}

class _DeliveriesHistoryPageState extends State<DeliveriesHistoryPage> {
  int _activeMenuIndex = 2;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController txtPesquisa = TextEditingController();

  String _queryAtiva = '';

  Set<String> _restaurantesSelecionados = {};
  FiltroDatas? _filtroDatasAtivo;

  List<Entrega> _aplicarFiltros(List<Entrega> entregas) {
    final ordenadas = List<Entrega>.from(entregas)
      ..sort((a, b) => b.data.compareTo(a.data));

    return ordenadas.where((entrega) {
      final matchesQuery =
          _queryAtiva.isEmpty ||
          entrega.restaurante.toLowerCase().contains(_queryAtiva.toLowerCase());
      final matchesRestaurante =
          _restaurantesSelecionados.isEmpty ||
          _restaurantesSelecionados.contains(entrega.restaurante);
      bool matchesPeriodo = true;
      if (_filtroDatasAtivo != null) {
        final intervalo = _filtroDatasAtivo!.intervalo;
        matchesPeriodo =
            !entrega.data.isBefore(intervalo.start) &&
            !entrega.data.isAfter(intervalo.end);
      }

      return matchesQuery && matchesRestaurante && matchesPeriodo;
    }).toList();
  }

  List<String> _extrairRestaurantes(List<Entrega> entregas) {
    return entregas.map((e) => e.restaurante).toSet().toList()..sort();
  }

  bool get _temFiltrosAtivos =>
      _restaurantesSelecionados.isNotEmpty ||
      _filtroDatasAtivo != null ||
      _queryAtiva.isNotEmpty;

  void _limparFiltros() {
    setState(() {
      _restaurantesSelecionados = {};
      _filtroDatasAtivo = null;
      _queryAtiva = '';
      txtPesquisa.clear();
    });
  }

  void _abrirFiltroRestaurante(
    BuildContext context,
    List<String> restaurantes,
  ) {
    Set<String> selecaoTemporaria = Set.from(_restaurantesSelecionados);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF5F2E9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      useSafeArea: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filtrar por Restaurante',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (selecaoTemporaria.isNotEmpty)
                        TextButton(
                          onPressed: () =>
                              setModalState(() => selecaoTemporaria.clear()),
                          child: const Text(
                            'Limpar',
                            style: TextStyle(color: Color(0xFF388E3C)),
                          ),
                        ),
                    ],
                  ),
                  const Divider(color: Color(0xFFF7E18B), thickness: 2),
                  const SizedBox(height: 8),
                  if (restaurantes.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text('Nenhum restaurante encontrado.'),
                      ),
                    )
                  else
                    ...restaurantes.map((restaurante) {
                      return CheckboxListTile(
                        title: Text(restaurante),
                        value: selecaoTemporaria.contains(restaurante),
                        activeColor: const Color(0xFF388E3C),
                        checkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onChanged: (bool? value) {
                          setModalState(() {
                            if (value == true) {
                              selecaoTemporaria.add(restaurante);
                            } else {
                              selecaoTemporaria.remove(restaurante);
                            }
                          });
                        },
                      );
                    }),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(
                          () => _restaurantesSelecionados = selecaoTemporaria,
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF388E3C),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Confirmar'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _abrirFiltroDatas(BuildContext context) {
    FiltroDatas? selecaoTemporaria = _filtroDatasAtivo;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF5F2E9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      useSafeArea: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filtrar por Data',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (selecaoTemporaria != null)
                        TextButton(
                          onPressed: () =>
                              setModalState(() => selecaoTemporaria = null),
                          child: const Text(
                            'Limpar',
                            style: TextStyle(color: Color(0xFF388E3C)),
                          ),
                        ),
                    ],
                  ),
                  const Divider(color: Color(0xFFF7E18B), thickness: 2),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.6,
                    children: FiltroDatas.values.map((opcao) {
                      final isSelected = selecaoTemporaria == opcao;
                      return GestureDetector(
                        onTap: () => setModalState(() {
                          selecaoTemporaria = isSelected ? null : opcao;
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF388E3C)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF388E3C)
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                opcao.icon,
                                size: 18,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black54,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                opcao.label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _filtroDatasAtivo = selecaoTemporaria);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF388E3C),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Confirmar'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F2E9),
      drawer: Menu(selectedIndex: _activeMenuIndex),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: StreamBuilder<List<Entrega>>(
                stream: FirestoreService().buscarEntregas(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF388E3C),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Erro ao carregar o histórico.'),
                    );
                  }

                  final todasEntregas = snapshot.data ?? [];
                  final restaurantes = _extrairRestaurantes(todasEntregas);
                  final entregasFiltradas = _aplicarFiltros(todasEntregas);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Histórico',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildSearchField(),
                        const SizedBox(height: 12),
                        _buildFilterChips(context, restaurantes),
                        const SizedBox(height: 8),
                        if (_temFiltrosAtivos)
                          _buildActiveFiltersInfo(entregasFiltradas.length),

                        const SizedBox(height: 16),

                        if (todasEntregas.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Center(
                              child: Text(
                                'Nenhuma entrega registrada ainda.',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          )
                        else if (entregasFiltradas.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 48,
                                    color: Colors.black26,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Nenhuma entrega encontrada\ncom os filtros aplicados.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          _buildSectionReal(
                            'Todas as Entregas',
                            entregasFiltradas,
                          ),

                        const SizedBox(height: 80),
                      ],
                    ),
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
          color: const Color(0xFF388E3C),
          function: () => showDialog(
            context: context,
            builder: (BuildContext context) => ManualDeliveryForm(),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: txtPesquisa,
      textInputAction: TextInputAction.search,
      onSubmitted: (value) {
        setState(() => _queryAtiva = value.trim());
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Pesquise a entrega',
        hintStyle: const TextStyle(color: Colors.black38),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.search, color: Color(0xFF388E3C)),
          tooltip: 'Buscar',
          onPressed: () {
            FocusScope.of(context).unfocus();
            setState(() => _queryAtiva = txtPesquisa.text.trim());
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF388E3C), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, List<String> restaurantes) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        FilterChip(
          avatar: Icon(
            Icons.restaurant,
            size: 16,
            color: _restaurantesSelecionados.isNotEmpty
                ? Colors.white
                : Colors.black54,
          ),
          label: Text(
            _restaurantesSelecionados.isEmpty
                ? 'Restaurante'
                : 'Restaurante (${_restaurantesSelecionados.length})',
            style: TextStyle(
              color: _restaurantesSelecionados.isNotEmpty
                  ? Colors.white
                  : Colors.black87,
              fontWeight: _restaurantesSelecionados.isNotEmpty
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          selected: _restaurantesSelecionados.isNotEmpty,
          onSelected: (_) => _abrirFiltroRestaurante(context, restaurantes),
          selectedColor: const Color(0xFF388E3C),
          checkmarkColor: Colors.white,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),

        FilterChip(
          avatar: Icon(
            Icons.calendar_today,
            size: 16,
            color: _filtroDatasAtivo != null ? Colors.white : Colors.black54,
          ),
          label: Text(
            _filtroDatasAtivo?.label ?? 'Data',
            style: TextStyle(
              color: _filtroDatasAtivo != null ? Colors.white : Colors.black87,
              fontWeight: _filtroDatasAtivo != null
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          selected: _filtroDatasAtivo != null,
          onSelected: (_) => _abrirFiltroDatas(context),
          selectedColor: const Color(0xFF388E3C),
          checkmarkColor: Colors.white,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveFiltersInfo(int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 2),
      child: Row(
        children: [
          Text(
            '$count ${count == 1 ? 'resultado encontrado' : 'resultados encontrados'}',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: _limparFiltros,
            icon: const Icon(Icons.close, size: 14, color: Color(0xFFCC3300)),
            label: const Text(
              'Limpar filtros',
              style: TextStyle(fontSize: 13, color: Color(0xFFCC3300)),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: Color(0xFFF7E18B)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, size: 28),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const Text(
            'Entregas',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSectionReal(String title, List<Entrega> entregas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...entregas.map((entrega) {
          final dataFormatada = DateFormat(
            'dd/MM/yy HH:mm',
          ).format(entrega.data);

          return ActivityCard(
            icon: Icons.location_on,
            iconBackgroundColor: const Color(0xFF388E3C),
            time: dataFormatada,
            title: 'Entrega - ${entrega.restaurante}',
            subtitle: '${entrega.quilometragem} km rodados',
            amount: entrega.valor,
            isPositive: true,
          );
        }),
      ],
    );
  }
}
