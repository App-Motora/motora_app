import 'package:flutter/material.dart';
import 'package:motora_app/components/activity_card.dart';
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

class FilterSearch<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) getCategory;
  final DateTime Function(T) getDate;
  final String Function(T) getSearchText;
  final String Function(T) getTitle;
  final String Function(T) getSubtitle;
  final double Function(T) getAmount;
  final bool Function(T) getIsPositive;
  final void Function(T) onLongPress;
  final String searchHint;
  final String sectionTitle;
  final String categoryFilterLabel;
  final ActivityCardActionConfig Function(T) activityCardActions;

  const FilterSearch({
    super.key,
    required this.items,
    required this.getCategory,
    required this.getDate,
    required this.getSearchText,
    required this.getTitle,
    required this.getSubtitle,
    required this.getAmount,
    required this.getIsPositive,
    required this.onLongPress,
    this.searchHint = 'Pesquise',
    this.sectionTitle = 'Itens',
    this.categoryFilterLabel = 'Categoria',
    required this.activityCardActions
  });

  @override
  State<FilterSearch<T>> createState() => _FilterSearchState<T>();
}

class _FilterSearchState<T> extends State<FilterSearch<T>> {
  final TextEditingController txtPesquisa = TextEditingController();

  String _queryAtiva = '';

  Set<String> _categoriasSelecionadas = {};
  FiltroDatas? _filtroDatasAtivo;

  List<T> _aplicarFiltros(List<T> itens) {
    final ordenadas = List<T>.from(itens)
      ..sort((a, b) => widget.getDate(b).compareTo(widget.getDate(a)));

    return ordenadas.where((item) {
      final matchesQuery =
          _queryAtiva.isEmpty ||
          widget.getSearchText(item).toLowerCase().contains(_queryAtiva.toLowerCase());
      final matchesCategoria =
          _categoriasSelecionadas.isEmpty ||
          _categoriasSelecionadas.contains(widget.getCategory(item));
      bool matchesPeriodo = true;
      if (_filtroDatasAtivo != null) {
        final intervalo = _filtroDatasAtivo!.intervalo;
        matchesPeriodo =
            !widget.getDate(item).isBefore(intervalo.start) &&
            !widget.getDate(item).isAfter(intervalo.end);
      }

      return matchesQuery && matchesCategoria && matchesPeriodo;
    }).toList();
  }

  List<String> _extrairCategorias(List<T> itens) {
    return itens.map(widget.getCategory).toSet().toList()..sort();
  }

  bool get _temFiltrosAtivos =>
      _categoriasSelecionadas.isNotEmpty ||
      _filtroDatasAtivo != null ||
      _queryAtiva.isNotEmpty;

  void _limparFiltros() {
    setState(() {
      _categoriasSelecionadas = {};
      _filtroDatasAtivo = null;
      _queryAtiva = '';
      txtPesquisa.clear();
    });
  }

  void _abrirFiltroCategoria(
    BuildContext context,
    List<String> categorias,
  ) {
    Set<String> selecaoTemporaria = Set.from(_categoriasSelecionadas);

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
                      Text(
                        'Filtrar por ${widget.categoryFilterLabel}',
                        style: const TextStyle(
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
                  if (categorias.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text('Nenhuma categoria encontrada.'),
                      ),
                    )
                  else
                    ...categorias.map((categoria) {
                      return CheckboxListTile(
                        title: Text(categoria),
                        value: selecaoTemporaria.contains(categoria),
                        activeColor: const Color(0xFF388E3C),
                        checkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onChanged: (bool? value) {
                          setModalState(() {
                            if (value == true) {
                              selecaoTemporaria.add(categoria);
                            } else {
                              selecaoTemporaria.remove(categoria);
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
                          () => _categoriasSelecionadas = selecaoTemporaria,
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
    final categorias = _extrairCategorias(widget.items);
    final itensFiltrados = _aplicarFiltros(widget.items);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 20),
          Text(
            widget.sectionTitle,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          _buildSearchField(),
          const SizedBox(height: 12),
          _buildFilterChips(context, categorias),
          const SizedBox(height: 8),
          if (_temFiltrosAtivos)
            _buildActiveFiltersInfo(itensFiltrados.length),

          const SizedBox(height: 16),

          if (widget.items.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(
                child: Text(
                  'Nenhum item registrado ainda.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          else if (itensFiltrados.isEmpty)
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
                      'Nenhum item encontrado\ncom os filtros aplicados.',
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
            _buildSectionReal(widget.sectionTitle, itensFiltrados),

          const SizedBox(height: 80),
        ],
      ),
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
        hintText: widget.searchHint,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'Buscar',
          onPressed: () {
            FocusScope.of(context).unfocus();
            setState(() => _queryAtiva = txtPesquisa.text.trim());
          },
        )
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, List<String> categorias) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        FilterChip(
          avatar: Icon(
            Icons.category,
            size: 16,
            color: _categoriasSelecionadas.isNotEmpty
                ? Colors.white
                : Colors.black54,
          ),
          label: Text(
            _categoriasSelecionadas.isEmpty
                ? widget.categoryFilterLabel
                : '${widget.categoryFilterLabel} (${_categoriasSelecionadas.length})',
            style: TextStyle(
              color: _categoriasSelecionadas.isNotEmpty
                  ? Colors.white
                  : Colors.black87,
              fontWeight: _categoriasSelecionadas.isNotEmpty
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          selected: _categoriasSelecionadas.isNotEmpty,
          onSelected: (_) => _abrirFiltroCategoria(context, categorias),
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
            '$count ${count == 1 ? 'item encontrado' : 'itens encontrados'}',
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

  Widget _buildSectionReal(String title, List<T> itens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...itens.map((item) {
          final dataFormatada = DateFormat(
            'dd/MM/yy HH:mm',
          ).format(widget.getDate(item));

          return ActivityCard(
            icon: Icons.location_on,
            iconBackgroundColor: const Color(0xFF388E3C),
            time: dataFormatada,
            title: widget.getTitle(item),
            subtitle: widget.getSubtitle(item),
            amount: widget.getAmount(item),
            isPositive: widget.getIsPositive(item),
            actions: widget.activityCardActions(item),
          );
        }),
      ],
    );
  }
}