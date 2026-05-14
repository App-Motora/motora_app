import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:motora_app/components/menu.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  static const Color _backgroundColor = Color(0xFFF5F2E9);
  static const Color _incomeColor = Color(0xFF388E3C);
  static const Color _expenseColor = Color(0xFFFF7E55);
  static const Color _textColor = Color(0xFF2D2D2D);
  static const Color _mutedTextColor = Color(0xFF747474);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final List<_MonthOption> _monthOptions;
  late _MonthOption _selectedMonth;

  @override
  void initState() {
    super.initState();
    _monthOptions = _buildMonthOptions();
    _selectedMonth = _monthOptions.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _backgroundColor,
      drawer: const Menu(selectedIndex: 3),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            final report = _buildStaticMonthlyReport();

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopBar(),
                        const SizedBox(height: 22),
                        _buildBalanceCard(report),
                        const SizedBox(height: 28),
                        const Text(
                          'Despesas por categoria',
                          style: TextStyle(
                            color: _textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildCategoryCard(report),
                        const SizedBox(height: 28),
                        _buildDetailsCard(report),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        IconButton(
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          icon: const Icon(Icons.menu, color: _textColor),
          tooltip: 'Abrir menu',
        ),
        Expanded(
          child: Center(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<_MonthOption>(
                value: _selectedMonth,
                borderRadius: BorderRadius.circular(12),
                dropdownColor: Colors.white,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: _monthOptions
                    .map(
                      (month) => DropdownMenuItem<_MonthOption>(
                        value: month,
                        child: Text(
                          month.label,
                          style: const TextStyle(
                            color: _textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (month) {
                  if (month == null) return;
                  setState(() {
                    _selectedMonth = month;
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildBalanceCard(_MonthlyReport report) {
    final hasProfit = report.balance >= 0;
    final balanceColor = hasProfit ? _incomeColor : _expenseColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Text(
            hasProfit ? 'Lucro do mes' : 'Prejuizo do mes',
            style: const TextStyle(
              color: _mutedTextColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatCurrency(report.balance.abs()),
            style: TextStyle(
              color: balanceColor,
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _buildAmountPill(
                  icon: Icons.arrow_upward,
                  title: 'Receitas',
                  amount: report.income,
                  color: _incomeColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildAmountPill(
                  icon: Icons.arrow_downward,
                  title: 'Despesas',
                  amount: report.expenses,
                  color: _expenseColor,
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
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _mutedTextColor,
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

  Widget _buildCategoryCard(_MonthlyReport report) {
    final categories = report.categories;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: categories.isEmpty
          ? const SizedBox(
              height: 180,
              child: Center(
                child: Text(
                  'Nenhuma despesa registrada neste mes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _mutedTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 360;
                final chart = SizedBox(
                  width: 144,
                  height: 144,
                  child: CustomPaint(
                    painter: _DonutChartPainter(categories),
                    child: Center(
                      child: Text(
                        '${categories.length}',
                        style: const TextStyle(
                          color: _textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                );
                final legend = _buildCategoryLegend(categories);

                if (isCompact) {
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

  Widget _buildCategoryLegend(List<_CategorySlice> categories) {
    return Column(
      children: categories
          .map(
            (category) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: category.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _textColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _formatCurrency(category.amount),
                    style: const TextStyle(
                      color: _expenseColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDetailsCard(_MonthlyReport report) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumo do mes',
            style: TextStyle(
              color: _textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Entregas realizadas', '${report.deliveryCount}'),
          _buildDetailRow('Despesas registradas', '${report.expenseCount}'),
          _buildDetailRow(
            'Resultado',
            report.balance >= 0 ? 'Lucro' : 'Prejuizo',
            valueColor: report.balance >= 0 ? _incomeColor : _expenseColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _mutedTextColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? _textColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  _MonthlyReport _buildStaticMonthlyReport() {
    final monthSeed = _selectedMonth.month;
    final income = 3200.00 + (monthSeed * 210.75);
    final deliveryCount = 42 + monthSeed;
    final expenseCount = 9 + (monthSeed % 5);
    final groupedExpenses = <String, double>{
      'Combustivel': 820.00 + (monthSeed * 18.50),
      'Alimentacao': 360.00 + (monthSeed * 11.25),
      'Manutencao': 520.00 + (monthSeed * 8.75),
      'Outras': 210.00 + (monthSeed * 6.50),
    };
    final expenses = groupedExpenses.values.fold<double>(
      0,
      (total, amount) => total + amount,
    );

    final sortedCategories = groupedExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final categories = sortedCategories.asMap().entries.map((entry) {
      return _CategorySlice(
        name: entry.value.key,
        amount: entry.value.value,
        color: _categoryColors[entry.key % _categoryColors.length],
      );
    }).toList();

    return _MonthlyReport(
      income: income,
      expenses: expenses,
      balance: income - expenses,
      deliveryCount: deliveryCount,
      expenseCount: expenseCount,
      categories: categories,
    );
  }

  List<_MonthOption> _buildMonthOptions() {
    final now = DateTime.now();

    return List.generate(12, (index) {
      final date = DateTime(now.year, now.month - index);
      return _MonthOption(
        month: date.month,
        year: date.year,
        label: '${_monthNames[date.month - 1]} ${date.year}',
      );
    });
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  String _formatCurrency(double value) {
    final fixed = value.toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $fixed';
  }

  static const List<String> _monthNames = [
    'Janeiro',
    'Fevereiro',
    'Marco',
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

  static const List<Color> _categoryColors = [
    Color(0xFFFF7E55),
    Color(0xFFFF9F1C),
    Color(0xFFFFC857),
    Color(0xFFCC3300),
    Color(0xFFE86A33),
    Color(0xFFFFB08A),
  ];
}

class _DonutChartPainter extends CustomPainter {
  final List<_CategorySlice> categories;

  _DonutChartPainter(this.categories);

  @override
  void paint(Canvas canvas, Size size) {
    final total = categories.fold<double>(
      0,
      (total, category) => total + category.amount,
    );
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 28;

    var startAngle = -math.pi / 2;
    for (final category in categories) {
      final sweepAngle = (category.amount / total) * math.pi * 2;
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
}

class _MonthlyReport {
  final double income;
  final double expenses;
  final double balance;
  final int deliveryCount;
  final int expenseCount;
  final List<_CategorySlice> categories;

  const _MonthlyReport({
    required this.income,
    required this.expenses,
    required this.balance,
    required this.deliveryCount,
    required this.expenseCount,
    required this.categories,
  });
}

class _CategorySlice {
  final String name;
  final double amount;
  final Color color;

  const _CategorySlice({
    required this.name,
    required this.amount,
    required this.color,
  });
}
