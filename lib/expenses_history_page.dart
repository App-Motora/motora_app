import 'package:flutter/material.dart';
import 'package:motora_app/components/activity_card.dart';
import 'package:motora_app/components/automatic_expense_form.dart';
import 'package:motora_app/components/filter_search.dart';
import 'package:motora_app/components/float_button.dart';
import 'package:motora_app/components/menu.dart';

class ExpensesHistoryPage extends StatefulWidget {
  const ExpensesHistoryPage({super.key});

  @override
  State<ExpensesHistoryPage> createState() => _ExpensesHistoryPageState();
}

class _ExpensesHistoryPageState extends State<ExpensesHistoryPage> {
  static const Color _expenseColor = Color(0xFFFF7E55);
  static const Color _backgroundColor = Color(0xFFF5F2E9);

  final int _activeMenuIndex = 1;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final List<_StaticExpense> _expenses;

  @override
  void initState() {
    super.initState();
    _expenses = _buildStaticExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _backgroundColor,
      drawer: Menu(selectedIndex: _activeMenuIndex),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: FilterSearch<_StaticExpense>(
                items: _expenses,
                getCategory: (expense) => expense.category,
                getDate: (expense) => expense.date,
                getSearchText: (expense) =>
                    '${expense.category} ${expense.description}',
                getTitle: (expense) => expense.category,
                getSubtitle: (expense) => expense.description,
                getAmount: (expense) => expense.amount,
                getIsPositive: (expense) => false,
                onLongPress: (_) {},
                searchHint: 'Pesquise a despesa',
                sectionTitle: 'Historico',
                categoryFilterLabel: 'Categoria',
                accentColor: _expenseColor,
                cardIcon: Icons.receipt_long,
                activityCardActions: (_) => const ActivityCardActionConfig(
                  editIconColor: _expenseColor,
                  deleteIconColor: Color(0xFFCC3300),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8, right: 4),
        child: FloatButton(
          icon: Icons.add,
          color: _expenseColor,
          function: () => showDialog(
            context: context,
            builder: (BuildContext context) => const AutomaticExpenseForm(),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
            'Despesas',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  List<_StaticExpense> _buildStaticExpenses() {
    final now = DateTime.now();

    return [
      _StaticExpense(
        category: 'Combustivel',
        description: 'Abastecimento do turno',
        amount: 120.00,
        date: DateTime(now.year, now.month, now.day, 8, 45),
      ),
      _StaticExpense(
        category: 'Alimentacao',
        description: 'Almoco durante as entregas',
        amount: 32.50,
        date: DateTime(now.year, now.month, now.day, 12, 20),
      ),
      _StaticExpense(
        category: 'Manutencao',
        description: 'Troca de oleo',
        amount: 95.00,
        date: DateTime(now.year, now.month, now.day - 1, 17, 10),
      ),
      _StaticExpense(
        category: 'Combustivel',
        description: 'Completar tanque',
        amount: 80.00,
        date: DateTime(now.year, now.month, now.day - 2, 9, 5),
      ),
      _StaticExpense(
        category: 'Outras',
        description: 'Estacionamento',
        amount: 18.00,
        date: DateTime(now.year, now.month, now.day - 3, 15, 35),
      ),
      _StaticExpense(
        category: 'Manutencao',
        description: 'Calibragem e revisao rapida',
        amount: 24.90,
        date: DateTime(now.year, now.month, now.day - 6, 10, 0),
      ),
    ];
  }
}

class _StaticExpense {
  final String category;
  final String description;
  final double amount;
  final DateTime date;

  const _StaticExpense({
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
  });
}
