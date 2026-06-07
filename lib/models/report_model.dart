class ReportPeriod {
  final ReportPeriodType type;
  final DateTime start;
  final DateTime endExclusive;

  const ReportPeriod({
    required this.type,
    required this.start,
    required this.endExclusive,
  });

  bool contains(DateTime date) {
    return !date.isBefore(start) && date.isBefore(endExclusive);
  }
}

enum ReportPeriodType { day, week, month, custom }

class ReportBreakdownItem {
  final String label;
  final double amount;
  final int count;
  final double share;

  const ReportBreakdownItem({
    required this.label,
    required this.amount,
    required this.count,
    required this.share,
  });
}

class ReportBestDay {
  final DateTime date;
  final double income;
  final double expenses;
  final double balance;
  final int deliveryCount;

  const ReportBestDay({
    required this.date,
    required this.income,
    required this.expenses,
    required this.balance,
    required this.deliveryCount,
  });
}

class ReportSummary {
  final ReportPeriod period;
  final double income;
  final double expenses;
  final double balance;
  final double totalKm;
  final int deliveryCount;
  final int expenseCount;
  final int activeDays;
  final double averageTicket;
  final double averageExpensePerDelivery;
  final double profitPerKm;
  final double costPerKm;
  final double marginPercent;
  final ReportBestDay? bestDay;
  final ReportBreakdownItem? topRestaurant;
  final ReportBreakdownItem? topExpenseCategory;
  final List<ReportBreakdownItem> topRestaurants;
  final List<ReportBreakdownItem> expenseCategories;

  const ReportSummary({
    required this.period,
    required this.income,
    required this.expenses,
    required this.balance,
    required this.totalKm,
    required this.deliveryCount,
    required this.expenseCount,
    required this.activeDays,
    required this.averageTicket,
    required this.averageExpensePerDelivery,
    required this.profitPerKm,
    required this.costPerKm,
    required this.marginPercent,
    required this.bestDay,
    required this.topRestaurant,
    required this.topExpenseCategory,
    required this.topRestaurants,
    required this.expenseCategories,
  });

  bool get hasData =>
      income > 0 ||
      expenses > 0 ||
      deliveryCount > 0 ||
      expenseCount > 0 ||
      totalKm > 0;
}
