import 'package:motora_app/models/delivery_model.dart';
import 'package:motora_app/models/expense_model.dart';
import 'package:motora_app/models/report_model.dart';

class ReportService {
  const ReportService();

  ReportSummary buildReport({
    required List<Entrega> deliveries,
    required List<Despesa> expenses,
    required ReportPeriod period,
  }) {
    final filteredDeliveries = deliveries
        .where((delivery) => period.contains(delivery.data))
        .toList();
    final filteredExpenses = expenses
        .where((expense) => period.contains(expense.data))
        .toList();

    final income = filteredDeliveries.fold<double>(
      0,
      (total, delivery) => total + delivery.valor,
    );
    final totalExpenses = filteredExpenses.fold<double>(
      0,
      (total, expense) => total + expense.valor,
    );
    final totalKm = filteredDeliveries.fold<double>(
      0,
      (total, delivery) => total + delivery.quilometragem,
    );
    final balance = income - totalExpenses;
    final deliveryCount = filteredDeliveries.length;
    final expenseCount = filteredExpenses.length;

    final restaurantGroups = _groupDeliveriesByRestaurant(
      filteredDeliveries,
      totalAmount: income,
    );
    final categoryGroups = _groupExpensesByCategory(
      filteredExpenses,
      totalAmount: totalExpenses,
    );

    final bestDay = _buildBestDay(
      deliveries: filteredDeliveries,
      expenses: filteredExpenses,
    );

    final activeDays = _countActiveDays(
      deliveries: filteredDeliveries,
      expenses: filteredExpenses,
    );

    return ReportSummary(
      period: period,
      income: income,
      expenses: totalExpenses,
      balance: balance,
      totalKm: totalKm,
      deliveryCount: deliveryCount,
      expenseCount: expenseCount,
      activeDays: activeDays,
      averageTicket: deliveryCount == 0 ? 0 : income / deliveryCount,
      averageExpensePerDelivery: deliveryCount == 0
          ? 0
          : totalExpenses / deliveryCount,
      profitPerKm: totalKm == 0 ? 0 : balance / totalKm,
      costPerKm: totalKm == 0 ? 0 : totalExpenses / totalKm,
      marginPercent: income == 0 ? 0 : (balance / income) * 100,
      bestDay: bestDay,
      topRestaurant: restaurantGroups.isEmpty ? null : restaurantGroups.first,
      topExpenseCategory: categoryGroups.isEmpty ? null : categoryGroups.first,
      topRestaurants: restaurantGroups,
      expenseCategories: categoryGroups,
    );
  }

  int _countActiveDays({
    required List<Entrega> deliveries,
    required List<Despesa> expenses,
  }) {
    final activeDays = <DateTime>{};

    for (final delivery in deliveries) {
      activeDays.add(_dateOnly(delivery.data));
    }

    for (final expense in expenses) {
      activeDays.add(_dateOnly(expense.data));
    }

    return activeDays.length;
  }

  ReportBestDay? _buildBestDay({
    required List<Entrega> deliveries,
    required List<Despesa> expenses,
  }) {
    if (deliveries.isEmpty && expenses.isEmpty) return null;

    final groupedDays = <DateTime, _DayAccumulator>{};

    for (final delivery in deliveries) {
      final day = _dateOnly(delivery.data);
      final accumulator = groupedDays.putIfAbsent(day, _DayAccumulator.new);
      accumulator.income += delivery.valor;
      accumulator.balance += delivery.valor;
      accumulator.deliveryCount += 1;
    }

    for (final expense in expenses) {
      final day = _dateOnly(expense.data);
      final accumulator = groupedDays.putIfAbsent(day, _DayAccumulator.new);
      accumulator.expenses += expense.valor;
      accumulator.balance -= expense.valor;
    }

    final bestEntry = groupedDays.entries.reduce((currentBest, nextEntry) {
      final current = currentBest.value;
      final next = nextEntry.value;

      if (next.balance > current.balance) return nextEntry;
      if (next.balance < current.balance) return currentBest;

      if (next.income > current.income) return nextEntry;
      if (next.income < current.income) return currentBest;

      return nextEntry.key.isAfter(currentBest.key) ? nextEntry : currentBest;
    });

    return ReportBestDay(
      date: bestEntry.key,
      income: bestEntry.value.income,
      expenses: bestEntry.value.expenses,
      balance: bestEntry.value.balance,
      deliveryCount: bestEntry.value.deliveryCount,
    );
  }

  List<ReportBreakdownItem> _groupDeliveriesByRestaurant(
    List<Entrega> deliveries, {
    required double totalAmount,
  }) {
    final groups = <String, _BreakdownAccumulator>{};

    for (final item in deliveries) {
      final rawLabel = item.restaurante.trim();
      final label = rawLabel.isEmpty ? 'Nao informado' : rawLabel;
      final key = label.toLowerCase();
      final accumulator = groups.putIfAbsent(
        key,
        () => _BreakdownAccumulator(label: label),
      );

      accumulator.amount += item.valor;
      accumulator.count += 1;
    }

    return _buildBreakdownResult(groups, totalAmount: totalAmount);
  }

  List<ReportBreakdownItem> _groupExpensesByCategory(
    List<Despesa> expenses, {
    required double totalAmount,
  }) {
    final groups = <String, _BreakdownAccumulator>{};

    for (final item in expenses) {
      final rawLabel = item.categoria.trim();
      final label = rawLabel.isEmpty ? 'Nao informado' : rawLabel;
      final key = label.toLowerCase();
      final accumulator = groups.putIfAbsent(
        key,
        () => _BreakdownAccumulator(label: label),
      );

      accumulator.amount += item.valor;
      accumulator.count += 1;
    }

    return _buildBreakdownResult(groups, totalAmount: totalAmount);
  }

  List<ReportBreakdownItem> _buildBreakdownResult(
    Map<String, _BreakdownAccumulator> groups, {
    required double totalAmount,
  }) {
    final result =
        groups.values
            .map(
              (group) => ReportBreakdownItem(
                label: group.label,
                amount: group.amount,
                count: group.count,
                share: totalAmount == 0 ? 0 : group.amount / totalAmount,
              ),
            )
            .toList()
          ..sort((a, b) => b.amount.compareTo(a.amount));

    return result;
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}

class _BreakdownAccumulator {
  final String label;
  double amount = 0;
  int count = 0;

  _BreakdownAccumulator({required this.label});
}

class _DayAccumulator {
  double income = 0;
  double expenses = 0;
  double balance = 0;
  int deliveryCount = 0;
}
