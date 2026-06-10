import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:motora_app/components/menu.dart';
import 'package:motora_app/constants/app_colors.dart';
import 'package:motora_app/models/delivery_model.dart';
import 'package:motora_app/models/expense_model.dart';
import 'package:motora_app/models/report_model.dart';
import 'package:motora_app/services/firestore_service.dart';
import 'package:motora_app/services/report_service.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  static const List<String> _monthNames = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  static const List<String> _weekdayNames = [
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sáb',
    'Dom',
  ];

  static const List<Color> _categoryColors = [
    AppColors.corDespesa,
    AppColors.corSecundaria,
    AppColors.corPrincipal,
    AppColors.corExcluir,
    AppColors.corErro,
    AppColors.corEntrega,
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirestoreService _firestoreService = FirestoreService();
  final ReportService _reportService = const ReportService();

  late _MonthOption _selectedMonth;
  _ReportPreset _selectedPreset = _ReportPreset.month;
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = _MonthOption(
      month: now.month,
      year: now.year,
      label: '${_monthNames[now.month - 1]} ${now.year}',
    );
  }

  List<_MonthOption> _getDynamicMonthOptions(
    List<Entrega> deliveries,
    List<Despesa> expenses,
  ) {
    final now = DateTime.now();
    final Set<String> activeYearMonths = {};
    activeYearMonths.add('${now.year}-${now.month}');
    for (var d in deliveries) {
      activeYearMonths.add('${d.data.year}-${d.data.month}');
    }
    for (var e in expenses) {
      activeYearMonths.add('${e.data.year}-${e.data.month}');
    }

    final List<_MonthOption> options = [];
    for (var ym in activeYearMonths) {
      final parts = ym.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      options.add(
        _MonthOption(
          month: month,
          year: year,
          label: '${_monthNames[month - 1]} $year',
        ),
      );
    }
    options.sort((a, b) {
      if (a.year != b.year) return b.year.compareTo(a.year);
      return b.month.compareTo(a.month);
    });

    return options;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.corFundo,
      drawer: const Menu(selectedIndex: 3),
      body: SafeArea(
        child: StreamBuilder<List<Entrega>>(
          stream: _firestoreService.buscarEntregas(),
          builder: (context, deliveriesSnapshot) {
            return StreamBuilder<List<Despesa>>(
              stream: _firestoreService.buscarDespesas(),
              builder: (context, expensesSnapshot) {
                final isLoading =
                    deliveriesSnapshot.connectionState ==
                        ConnectionState.waiting ||
                    expensesSnapshot.connectionState == ConnectionState.waiting;

                if (isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.corSecundaria,
                    ),
                  );
                }

                if (deliveriesSnapshot.hasError || expensesSnapshot.hasError) {
                  return _buildErrorState();
                }

                final deliveries = deliveriesSnapshot.data ?? const [];
                final expenses = expensesSnapshot.data ?? const [];
                final dynamicMonthOptions = _getDynamicMonthOptions(
                  deliveries,
                  expenses,
                );
                final effectiveSelectedMonth =
                    dynamicMonthOptions.contains(_selectedMonth)
                    ? _selectedMonth
                    : dynamicMonthOptions.first;

                final report = _reportService.buildReport(
                  deliveries: deliveries,
                  expenses: expenses,
                  period: _currentPeriod(effectiveSelectedMonth),
                );

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(
                            report,
                            dynamicMonthOptions,
                            effectiveSelectedMonth,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!report.hasData) ...[
                                  _buildEmptyStateCard(),
                                  const SizedBox(height: 24),
                                ],
                                _buildSectionTitle('Panorama do Período'),
                                const SizedBox(height: 14),
                                _buildMetricsGrid(report),
                                const SizedBox(height: 24),
                                _buildSectionTitle('Ganhos vs Gastos'),
                                const SizedBox(height: 14),
                                _buildCashflowCard(report),
                                const SizedBox(height: 24),
                                _buildSectionTitle('Top Restaurantes'),
                                const SizedBox(height: 14),
                                _buildRestaurantsCard(report),
                                const SizedBox(height: 24),
                                _buildSectionTitle('Despesas por Categoria'),
                                const SizedBox(height: 14),
                                _buildCategoryCard(report),
                                const SizedBox(height: 24),
                                _buildSectionTitle('Insights do Período'),
                                const SizedBox(height: 14),
                                _buildInsightsCard(report),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        _buildTopBar(),
        const Expanded(
          child: Center(child: Text('Erro ao carregar os relatórios.')),
        ),
      ],
    );
  }

  Widget _buildHeader(
    ReportSummary report,
    List<_MonthOption> options,
    _MonthOption effectiveMonth,
  ) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: AppColors.corPrincipal),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopBar(),
          const SizedBox(height: 14),
          _buildPresetFilters(),
          const SizedBox(height: 14),
          _buildPeriodControl(options, effectiveMonth),
          const SizedBox(height: 18),
          _buildBalanceCard(report, effectiveMonth),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.menu, size: 30),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        const Expanded(
          child: Text(
            'Relatórios',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.corTexto,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildPresetFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPresetChip(
            label: 'Hoje',
            selected: _selectedPreset == _ReportPreset.day,
            onTap: () => _selectPreset(_ReportPreset.day),
          ),
          _buildPresetChip(
            label: 'Esta semana',
            selected: _selectedPreset == _ReportPreset.week,
            onTap: () => _selectPreset(_ReportPreset.week),
          ),
          _buildPresetChip(
            label: 'Este mês',
            selected: _selectedPreset == _ReportPreset.month,
            onTap: () => _selectPreset(_ReportPreset.month),
          ),
          _buildPresetChip(
            label: 'Personalizado',
            selected: _selectedPreset == _ReportPreset.custom,
            onTap: () => _selectPreset(_ReportPreset.custom),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.corSecundaria
                  : AppColors.corFundoMenu,
              borderRadius: BorderRadius.circular(999),
              border: selected
                  ? null
                  : Border.all(color: AppColors.corBordaInputs),
              boxShadow: [
                BoxShadow(
                  color: AppColors.corSombra.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected) ...[
                  const Icon(
                    Icons.check_rounded,
                    color: AppColors.corIconeClaro,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? AppColors.corIconeClaro
                        : AppColors.corTexto,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodControl(
    List<_MonthOption> options,
    _MonthOption effectiveMonth,
  ) {
    if (_selectedPreset == _ReportPreset.month) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return DropdownMenu<_MonthOption>(
            key: ValueKey(effectiveMonth.label),
            width: constraints.maxWidth,
            initialSelection: effectiveMonth,
            textStyle: const TextStyle(
              color: AppColors.corTexto,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            inputDecorationTheme: InputDecorationThemeData(
              filled: true,
              fillColor: AppColors.corInputs.withValues(alpha: 0.78),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide.none,
              ),
            ),
            dropdownMenuEntries: options.map((month) {
              final isSelected = month == effectiveMonth;
              return DropdownMenuEntry<_MonthOption>(
                value: month,
                label: month.label,
                style: AppColors.dropdownMenuItemStyle(isSelected),
              );
            }).toList(),
            onSelected: (month) {
              if (month == null) return;
              setState(() {
                _selectedMonth = month;
              });
            },
          );
        },
      );
    }

    if (_selectedPreset == _ReportPreset.custom) {
      return _buildPeriodPill(
        icon: Icons.date_range_outlined,
        title: 'Período personalizado',
        subtitle: _customRange == null
            ? 'Escolha um intervalo'
            : _formatDateRange(_customRange!),
        onTap: _pickCustomRange,
      );
    }

    final period = _currentPeriod(effectiveMonth);
    return _buildPeriodPill(
      icon: _selectedPreset == _ReportPreset.week
          ? Icons.calendar_view_week_outlined
          : Icons.today_outlined,
      title: _selectedPreset == _ReportPreset.week ? 'Esta semana' : 'Hoje',
      subtitle: _formatPeriodDates(period),
    );
  }

  Widget _buildPeriodPill({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.corInputs.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.corSombra.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.corSecundaria.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.corSecundaria),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.corTexto,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.corTexto.withValues(alpha: 0.62),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.corTexto,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(ReportSummary report, _MonthOption effectiveMonth) {
    final hasProfit = report.balance >= 0;
    final balanceColor = hasProfit
        ? AppColors.corEntrega
        : AppColors.corDespesa;
    final periodLabel = _selectedPreset == _ReportPreset.month
        ? effectiveMonth.label
        : _selectedPreset == _ReportPreset.custom && _customRange != null
        ? _formatDateRange(_customRange!)
        : _formatPeriodDates(report.period);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Text(
            hasProfit ? 'Lucro do período' : 'Prejuízo do período',
            style: TextStyle(
              color: AppColors.corTexto.withValues(alpha: 0.62),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            periodLabel,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.corTexto.withValues(alpha: 0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _formatCurrency(report.balance.abs()),
            style: TextStyle(
              color: balanceColor,
              fontSize: 38,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _buildAmountPill(
                  icon: Icons.arrow_upward_rounded,
                  title: 'Receitas',
                  amount: report.income,
                  color: AppColors.corEntrega,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildAmountPill(
                  icon: Icons.arrow_downward_rounded,
                  title: 'Despesas',
                  amount: report.expenses,
                  color: AppColors.corDespesa,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountPill({
    required IconData icon,
    required String title,
    required double amount,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.corIconeClaro, size: 24),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.corTexto.withValues(alpha: 0.62),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text(
                  _formatCurrency(amount),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.corSecundaria.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.insights_outlined,
              color: AppColors.corSecundaria,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Não encontramos movimentações nesse período ainda. Assim que você registrar entregas ou despesas, as informações serão atualizadas aqui.',
              style: TextStyle(
                color: AppColors.corTexto.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.corTexto,
        fontSize: 26,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  void _mostrarExplicacao(String titulo, String explicacao) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.corFundoMenu,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.corTexto),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(
                  color: AppColors.corTexto,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          explicacao,
          style: TextStyle(
            color: AppColors.corTexto.withValues(alpha: 0.8),
            height: 1.4,
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Entendi',
              style: TextStyle(
                color: AppColors.corTexto,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(ReportSummary report) {
    final metrics = [
      _MetricTileData(
        title: 'Total de entregas',
        value: '${report.deliveryCount}',
        subtitle: 'Registros no período',
        icon: Icons.delivery_dining,
        color: AppColors.corEntrega,
        explicacao:
            'Representa a contagem de todas as entregas concluídas no período selecionado.',
      ),
      _MetricTileData(
        title: 'Km rodados',
        value: _formatKm(report.totalKm),
        subtitle: 'Distância acumulada',
        icon: Icons.route_outlined,
        color: AppColors.corSecundaria,
        explicacao:
            'A soma de toda a quilometragem percorrida durante as entregas do período.',
      ),
      _MetricTileData(
        title: 'Ticket Médio',
        value: _formatCurrency(report.averageTicket),
        subtitle: 'Média por entrega',
        icon: Icons.receipt_long_outlined,
        color: AppColors.corPrincipal,
        explicacao:
            'A média de valor que você ganha por entrega (Ganhos Totais divididos pelo Número de Entregas).',
      ),
      _MetricTileData(
        title: 'Lucro / km',
        value: _formatCurrency(report.profitPerKm),
        subtitle: 'Retorno por distância',
        icon: Icons.speed_outlined,
        color: AppColors.corSucesso,
        explicacao:
            'Seu lucro líquido dividido pela quilometragem total rodada. Mostra o valor real que vai para o seu bolso por cada quilômetro.',
      ),
      _MetricTileData(
        title: 'Despesa / Entrega',
        value: _formatCurrency(report.averageExpensePerDelivery),
        subtitle: 'Custo médio do período',
        icon: Icons.trending_down_rounded,
        color: AppColors.corDespesa,
        explicacao:
            'A soma de todas as suas despesas dividida pela quantidade de entregas realizadas no período.',
      ),
      _MetricTileData(
        title: 'Dias ativos',
        value: '${report.activeDays}',
        subtitle: 'Dias com movimento',
        icon: Icons.calendar_month_outlined,
        color: AppColors.corSecundaria,
        explicacao:
            'Quantidade de dias diferentes em que você registrou pelo menos uma entrega ou despesa.',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final itemWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: metrics
              .map(
                (metric) =>
                    SizedBox(width: itemWidth, child: _buildMetricCard(metric)),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildMetricCard(_MetricTileData metric) {
    return Material(
      color: AppColors.corFundoMenu,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _mostrarExplicacao(metric.title, metric.explicacao),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.corBordaInputs.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: metric.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(metric.icon, color: metric.color, size: 22),
              ),
              const SizedBox(height: 14),
              Text(
                metric.title,
                style: TextStyle(
                  color: AppColors.corTexto.withValues(alpha: 0.68),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  metric.value,
                  style: const TextStyle(
                    color: AppColors.corTexto,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                metric.subtitle,
                style: TextStyle(
                  color: AppColors.corTexto.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCashflowCard(ReportSummary report) {
    final total = report.income + report.expenses;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildCashflowLabel(
                  title: 'Ganhos',
                  amount: report.income,
                  color: AppColors.corEntrega,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCashflowLabel(
                  title: 'Gastos',
                  amount: report.expenses,
                  color: AppColors.corDespesa,
                  alignEnd: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final incomeWidth = total == 0
                    ? 0.0
                    : width * (report.income / total);
                final expenseWidth = total == 0
                    ? 0.0
                    : width * (report.expenses / total);

                return Container(
                  height: 18,
                  color: AppColors.corBordaInputs.withValues(alpha: 0.35),
                  child: total == 0
                      ? const SizedBox.expand()
                      : Stack(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: incomeWidth,
                                color: AppColors.corEntrega,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                width: expenseWidth,
                                color: AppColors.corDespesa,
                              ),
                            ),
                          ],
                        ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Text(
            report.balance >= 0
                ? 'Margem de Lucro: ${_formatPercent(report.marginPercent)}'
                : 'Prejuízo Acumulado: ${_formatCurrency(report.balance.abs())}',
            style: TextStyle(
              color: report.balance >= 0
                  ? AppColors.corEntrega
                  : AppColors.corDespesa,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashflowLabel({
    required String title,
    required double amount,
    required Color color,
    bool alignEnd = false,
  }) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatCurrency(amount),
          style: const TextStyle(
            color: AppColors.corTexto,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantsCard(ReportSummary report) {
    final items = report.topRestaurants.take(3).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: items.isEmpty
          ? _buildSectionEmptyMessage(
              'Nenhuma entrega encontrada nesse período.',
            )
          : Column(
              children: [
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: _buildRankingRow(
                      label: item.label,
                      amount: _formatCurrency(item.amount),
                      subtitle: '${item.count} Entregas',
                      progress: items.first.amount == 0
                          ? 0
                          : item.amount / items.first.amount,
                      color: AppColors.corSecundaria,
                    ),
                  ),
                ),
                if (report.topRestaurants.length > items.length)
                  Text(
                    '+${report.topRestaurants.length - items.length} Restaurantes com faturamento no período',
                    style: TextStyle(
                      color: AppColors.corTexto.withValues(alpha: 0.55),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildCategoryCard(ReportSummary report) {
    final compactItems = _compactBreakdown(
      report.expenseCategories,
      maxItems: 5,
      mergedLabel: 'Outras categorias',
    );
    final slices = compactItems.asMap().entries.map((entry) {
      return _ColoredBreakdownItem(
        item: entry.value,
        color: _categoryColors[entry.key % _categoryColors.length],
      );
    }).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: slices.isEmpty
          ? _buildSectionEmptyMessage(
              'Nenhuma despesa registrada nesse período.',
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final chart = SizedBox(
                  width: 170,
                  height: 170,
                  child: CustomPaint(
                    painter: _DonutChartPainter(slices),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${report.expenseCategories.length}',
                            style: const TextStyle(
                              color: AppColors.corTexto,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Categorias',
                            style: TextStyle(
                              color: AppColors.corTexto.withValues(alpha: 0.54),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );

                final legend = Column(
                  children: slices
                      .map(
                        (slice) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: Row(
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: slice.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  slice.item.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.corTexto,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _formatCurrency(slice.item.amount),
                                style: const TextStyle(
                                  color: AppColors.corDespesa,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                );

                if (constraints.maxWidth < 380) {
                  return Column(
                    children: [chart, const SizedBox(height: 18), legend],
                  );
                }

                return Row(
                  children: [
                    chart,
                    const SizedBox(width: 22),
                    Expanded(child: legend),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildInsightsCard(ReportSummary report) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _buildInsightRow(
            icon: Icons.emoji_events_outlined,
            color: AppColors.corSecundaria,
            label: 'Melhor dia',
            value: report.bestDay == null
                ? 'Sem dados'
                : '${_formatWeekday(report.bestDay!.date)}, ${_formatShortDate(report.bestDay!.date)}',
            trailing: report.bestDay == null
                ? null
                : _formatCurrency(report.bestDay!.balance),
          ),
          _buildInsightRow(
            icon: Icons.restaurant_outlined,
            color: AppColors.corEntrega,
            label: 'Restaurante líder',
            value: report.topRestaurant?.label ?? 'Sem dados',
            trailing: report.topRestaurant == null
                ? null
                : _formatCurrency(report.topRestaurant!.amount),
          ),
          _buildInsightRow(
            icon: Icons.sell_outlined,
            color: AppColors.corDespesa,
            label: 'Maior gasto',
            value: report.topExpenseCategory?.label ?? 'Sem dados',
            trailing: report.topExpenseCategory == null
                ? null
                : _formatCurrency(report.topExpenseCategory!.amount),
          ),
          _buildInsightRow(
            icon: Icons.percent_rounded,
            color: report.balance >= 0
                ? AppColors.corEntrega
                : AppColors.corDespesa,
            label: 'Margem do período',
            value: _formatPercent(report.marginPercent),
          ),
          _buildInsightRow(
            icon: Icons.receipt_long_outlined,
            color: AppColors.corSecundaria,
            label: 'Despesas registradas',
            value: '${report.expenseCount}',
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    String? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.corTexto.withValues(alpha: 0.56),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.corTexto,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null)
            Text(
              trailing,
              style: const TextStyle(
                color: AppColors.corTexto,
                fontWeight: FontWeight.w900,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRankingRow({
    required String label,
    required String amount,
    required double progress,
    required Color color,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.corTexto,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              amount,
              style: const TextStyle(
                color: AppColors.corTexto,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: AppColors.corTexto.withValues(alpha: 0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 14,
            value: progress.clamp(0.0, 1.0),
            color: color,
            backgroundColor: color.withValues(alpha: 0.14),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionEmptyMessage(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.corTexto.withValues(alpha: 0.56),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> _selectPreset(_ReportPreset preset) async {
    if (preset == _ReportPreset.custom) {
      await _pickCustomRange();
      return;
    }

    if (!mounted) return;
    setState(() {
      _selectedPreset = preset;
    });
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final initialRange =
        _customRange ??
        DateTimeRange(start: now.subtract(const Duration(days: 6)), end: now);

    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDateRange: initialRange,
      currentDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.corSecundaria,
              surface: AppColors.corFundoMenu,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (pickedRange == null || !mounted) return;

    setState(() {
      _customRange = DateTimeRange(
        start: _dateOnly(pickedRange.start),
        end: _dateOnly(pickedRange.end),
      );
      _selectedPreset = _ReportPreset.custom;
    });
  }

  ReportPeriod _currentPeriod(_MonthOption currentMonth) {
    final now = DateTime.now();
    final today = _dateOnly(now);

    switch (_selectedPreset) {
      case _ReportPreset.day:
        return ReportPeriod(
          type: ReportPeriodType.day,
          start: today,
          endExclusive: today.add(const Duration(days: 1)),
        );
      case _ReportPreset.week:
        final start = today.subtract(Duration(days: today.weekday - 1));
        return ReportPeriod(
          type: ReportPeriodType.week,
          start: start,
          endExclusive: start.add(const Duration(days: 7)),
        );
      case _ReportPreset.custom:
        final customRange = _customRange;
        if (customRange != null) {
          return ReportPeriod(
            type: ReportPeriodType.custom,
            start: _dateOnly(customRange.start),
            endExclusive: _dateOnly(
              customRange.end,
            ).add(const Duration(days: 1)),
          );
        }
        return ReportPeriod(
          type: ReportPeriodType.month,
          start: DateTime(currentMonth.year, currentMonth.month),
          endExclusive: DateTime(currentMonth.year, currentMonth.month + 1),
        );
      case _ReportPreset.month:
        return ReportPeriod(
          type: ReportPeriodType.month,
          start: DateTime(currentMonth.year, currentMonth.month),
          endExclusive: DateTime(currentMonth.year, currentMonth.month + 1),
        );
    }
  }

  List<ReportBreakdownItem> _compactBreakdown(
    List<ReportBreakdownItem> items, {
    required int maxItems,
    required String mergedLabel,
  }) {
    if (items.length <= maxItems) return items;

    final visible = items.take(maxItems - 1).toList();
    final hidden = items.skip(maxItems - 1).toList();
    final mergedAmount = hidden.fold<double>(
      0,
      (total, item) => total + item.amount,
    );
    final mergedCount = hidden.fold<int>(
      0,
      (total, item) => total + item.count,
    );
    final mergedShare = hidden.fold<double>(
      0,
      (total, item) => total + item.share,
    );

    visible.add(
      ReportBreakdownItem(
        label: mergedLabel,
        amount: mergedAmount,
        count: mergedCount,
        share: mergedShare,
      ),
    );

    return visible;
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.corFundoMenu,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: AppColors.corSombra.withValues(alpha: 0.06),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  String _formatCurrency(double value) {
    final absoluteCents = (value.abs() * 100).round();
    final integerPart = absoluteCents ~/ 100;
    final decimalPart = absoluteCents % 100;
    final integerText = integerPart.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    final decimalText = decimalPart.toString().padLeft(2, '0');
    final prefix = value < 0 ? '-R\$ ' : 'R\$ ';
    return '$prefix$integerText,$decimalText';
  }

  String _formatKm(double value) {
    return '${value.toStringAsFixed(1).replaceAll('.', ',')} km';
  }

  String _formatPercent(double value) {
    return '${value.toStringAsFixed(1).replaceAll('.', ',')}%';
  }

  String _formatPeriodDates(ReportPeriod period) {
    final endDate = period.endExclusive.subtract(const Duration(days: 1));
    return _formatDateRange(
      DateTimeRange(start: period.start, end: endDate),
      compactSingleDay: true,
    );
  }

  String _formatDateRange(
    DateTimeRange range, {
    bool compactSingleDay = false,
  }) {
    if (_isSameDay(range.start, range.end)) {
      return _formatShortDate(range.start);
    }

    return '${_formatShortDate(range.start)} - ${_formatShortDate(range.end)}';
  }

  String _formatShortDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = _monthNames[value.month - 1].substring(0, 3);
    return '$day $month';
  }

  String _formatWeekday(DateTime value) {
    return _weekdayNames[value.weekday - 1];
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<_ColoredBreakdownItem> categories;

  _DonutChartPainter(this.categories);

  @override
  void paint(Canvas canvas, Size size) {
    final total = categories.fold<double>(
      0,
      (sum, item) => sum + item.item.amount,
    );
    if (total <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 28;

    var startAngle = -math.pi / 2;
    for (final category in categories) {
      final sweepAngle = (category.item.amount / total) * math.pi * 2;
      paint.color = category.color;
      canvas.drawArc(rect, startAngle, sweepAngle - 0.04, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.categories != categories;
  }
}

class _MonthOption {
  final int month;
  final int year;
  final String label;

  const _MonthOption({
    required this.month,
    required this.year,
    required this.label,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _MonthOption &&
          runtimeType == other.runtimeType &&
          month == other.month &&
          year == other.year;

  @override
  int get hashCode => month.hashCode ^ year.hashCode;
}

class _MetricTileData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String explicacao;

  const _MetricTileData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.explicacao,
  });
}

class _ColoredBreakdownItem {
  final ReportBreakdownItem item;
  final Color color;

  const _ColoredBreakdownItem({required this.item, required this.color});
}

enum _ReportPreset { day, week, month, custom }
