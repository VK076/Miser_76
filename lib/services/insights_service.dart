import '../models/expense.dart';
import '../models/budget.dart';
import '../models/income.dart';
import '../models/goal.dart';
import '../models/wallet.dart';
import 'expense_database.dart';
import 'budget_database.dart';
import 'income_database.dart';
import 'goal_database.dart';
import 'wallet_database.dart';

class Insight {
  final String title;
  final String description;
  final String type; // 'success', 'warning', 'info', 'error'
  final double? value;
  final String? category;

  Insight({
    required this.title,
    required this.description,
    required this.type,
    this.value,
    this.category,
  });
}

class MonthComparison {
  final double currentMonth;
  final double previousMonth;
  final double percentageChange;
  final bool isIncrease;

  MonthComparison({
    required this.currentMonth,
    required this.previousMonth,
    required this.percentageChange,
    required this.isIncrease,
  });
}

class CategorySpending {
  final String category;
  final double amount;
  final double percentage;

  CategorySpending({
    required this.category,
    required this.amount,
    required this.percentage,
  });
}

class InsightsService {
  final ExpenseDatabase _expenseDb = ExpenseDatabase();
  final BudgetDatabase _budgetDb = BudgetDatabase();
  final IncomeDatabase _incomeDb = IncomeDatabase();
  final WalletDatabase _walletDb = WalletDatabase();
  final GoalDatabase _goalDb = GoalDatabase();

  // Calculate Net Worth: (Wallet Balances + Goal Savings) - Liabilities (Credit Card negative balance)
  // Note: Wallet balance already accounts for expenses/income.
  double getNetWorth() {
    final wallets = _walletDb.getAllWallets();
    final goals = _goalDb.getAllGoals();

    // 1. Wallets
    // Helper to calculate dynamic balance (since wallet.balance is initial)
    // We duplicates logic from ManageWalletsScreen here. ideally should be in Wallet model or Service.
    // For now, let's just sum wallet.balance field (which we are NOT updating? Wait.
    // In ManageWalletsScreen we calculated it dynamically.
    // We should implement `getWalletBalance(wallet)` helper here too or use Wallet properties if we updated them.
    // The previous implementation used dynamic calculation.
    
    double totalWalletBalance = 0;
    for (var wallet in wallets) {
       totalWalletBalance += _calculateWalletBalance(wallet);
    }

    // 2. Goals
    // Goal "savedAmount" (initial) + contributions.
    // We need to calculate total saved for goals.
    double totalGoalSavings = 0;
    for (var goal in goals) {
      totalGoalSavings += goal.initialSavedAmount;
      totalGoalSavings += _expenseDb.getTotalSavedForGoal(goal.id);
    }

    return totalWalletBalance + totalGoalSavings;
  }

  double _calculateWalletBalance(Wallet wallet) {
    // Basic implementation mirroring ManageWalletsScreen
    // Only if we don't have this in WalletDatabase or Wallet model
    final expenses = _expenseDb.getExpensesByWallet(wallet.id);
    final income = _incomeDb.getIncomeByWallet(wallet.id);
    
    final totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final totalIncome = income.fold(0.0, (sum, i) => sum + i.amount);
    
    return wallet.balance + totalIncome - totalExpenses;
  }

  // Calculate Savings Rate: (Income - Expenses) / Income
  // "Expenses" should exclude Goal contributions ideally if we treat them as savings.
  double getCurrentMonthSavingsRate() {
    final now = DateTime.now();
    final currentMonthIncomeList = _incomeDb.getAllIncome().where((i) =>
        i.date.year == now.year && i.date.month == now.month);
    final currentMonthExpensesList = _expenseDb.getAllExpenses().where((e) =>
        e.date.year == now.year && e.date.month == now.month);

    final totalIncome = currentMonthIncomeList.fold(0.0, (sum, i) => sum + i.amount);
    
    // We should allow filtering "Savings" category or Goal contributions as NOT expense.
    // For simplicity: Expenses with `goalId != null` are savings.
    final totalSpending = currentMonthExpensesList.fold(0.0, (sum, e) {
      if (e.goalId != null) return sum; // Treat contribution as saving, not spending
      return sum + e.amount;
    });

    if (totalIncome == 0) return 0.0;
    
    return ((totalIncome - totalSpending) / totalIncome) * 100;
  }

  // Get month-over-month spending comparison
  MonthComparison getMonthlyComparison() {
    final now = DateTime.now();
    final currentMonthExpenses = _expenseDb.getAllExpenses().where((e) =>
        e.date.year == now.year && e.date.month == now.month);
    final previousMonth = DateTime(now.year, now.month - 1);
    final previousMonthExpenses = _expenseDb.getAllExpenses().where((e) =>
        e.date.year == previousMonth.year && e.date.month == previousMonth.month);

    final currentTotal = currentMonthExpenses.fold(0.0, (sum, e) => sum + e.amount);
    final previousTotal = previousMonthExpenses.fold(0.0, (sum, e) => sum + e.amount);

    final change = currentTotal - previousTotal;
    final percentageChange = previousTotal > 0 ? (change / previousTotal * 100) : 0.0;

    return MonthComparison(
      currentMonth: currentTotal,
      previousMonth: previousTotal,
      percentageChange: percentageChange.abs(),
      isIncrease: change > 0,
    );
  }

  // Get top spending categories
  List<CategorySpending> getTopSpendingCategories({int limit = 5}) {
    final now = DateTime.now();
    final currentMonthExpenses = _expenseDb.getAllExpenses().where((e) =>
        e.date.year == now.year && e.date.month == now.month).toList();

    final Map<String, double> categoryTotals = {};
    double total = 0;

    for (var expense in currentMonthExpenses) {
      categoryTotals[expense.category] = 
          (categoryTotals[expense.category] ?? 0) + expense.amount;
      total += expense.amount;
    }

    final categories = categoryTotals.entries.map((entry) {
      return CategorySpending(
        category: entry.key,
        amount: entry.value,
        percentage: total > 0 ? (entry.value / total * 100) : 0,
      );
    }).toList();

    categories.sort((a, b) => b.amount.compareTo(a.amount));
    return categories.take(limit).toList();
  }

  // Get budget alerts
  List<Insight> getBudgetAlerts() {
    final insights = <Insight>[];
    final budgets = _budgetDb.getMonthlyBudgets();
    final now = DateTime.now();

    for (var budget in budgets) {
      final expenses = _expenseDb.getAllExpenses().where((e) =>
          e.category == budget.category &&
          e.date.year == now.year &&
          e.date.month == now.month);
      
      final spent = expenses.fold(0.0, (sum, e) => sum + e.amount);
      final percentage = (spent / budget.amount * 100);

      if (spent > budget.amount) {
        insights.add(Insight(
          title: '${budget.category} Over Budget',
          description: 'You\'ve exceeded your ${budget.category} budget by ${(spent - budget.amount).toStringAsFixed(2)}',
          type: 'error',
          value: percentage,
          category: budget.category,
        ));
      } else if (percentage > 80) {
        insights.add(Insight(
          title: '${budget.category} Alert',
          description: 'You\'ve used ${percentage.toStringAsFixed(0)}% of your ${budget.category} budget',
          type: 'warning',
          value: percentage,
          category: budget.category,
        ));
      }
    }

    return insights;
  }

  // Get savings opportunities
  List<Insight> getSavingsOpportunities() {
    final insights = <Insight>[];
    final comparison = getMonthlyComparison();
    final topCategories = getTopSpendingCategories(limit: 3);

    // Spending increase alert
    if (comparison.isIncrease && comparison.percentageChange > 10) {
      insights.add(Insight(
        title: 'Spending Increased',
        description: 'Your spending is up ${comparison.percentageChange.toStringAsFixed(1)}% from last month',
        type: 'warning',
        value: comparison.percentageChange,
      ));
    }

    // Spending decrease success
    if (!comparison.isIncrease && comparison.percentageChange > 5) {
      insights.add(Insight(
        title: 'Great Progress!',
        description: 'You\'ve reduced spending by ${comparison.percentageChange.toStringAsFixed(1)}% this month',
        type: 'success',
        value: comparison.percentageChange,
      ));
    }

    // High category spending
    if (topCategories.isNotEmpty && topCategories.first.percentage > 40) {
      insights.add(Insight(
        title: 'High ${topCategories.first.category} Spending',
        description: '${topCategories.first.category} accounts for ${topCategories.first.percentage.toStringAsFixed(0)}% of your spending',
        type: 'info',
        value: topCategories.first.percentage,
        category: topCategories.first.category,
      ));
    }

    // Income vs Expense
    final monthlyIncome = _incomeDb.getTotalIncome(_incomeDb.getCurrentMonthIncome());
    if (monthlyIncome > 0 && comparison.currentMonth > monthlyIncome) {
      insights.add(Insight(
        title: 'Spending Exceeds Income',
        description: 'You\'re spending more than you earn this month',
        type: 'error',
        value: comparison.currentMonth - monthlyIncome,
      ));
    } else if (monthlyIncome > 0) {
      final savingsRate = ((monthlyIncome - comparison.currentMonth) / monthlyIncome * 100);
      if (savingsRate > 20) {
        insights.add(Insight(
          title: 'Excellent Savings!',
          description: 'You\'re saving ${savingsRate.toStringAsFixed(0)}% of your income',
          type: 'success',
          value: savingsRate,
        ));
      }
    }

    return insights;
  }

  // Get all insights
  List<Insight> getAllInsights() {
    final insights = <Insight>[];
    insights.addAll(getBudgetAlerts());
    insights.addAll(getSavingsOpportunities());
    return insights;
  }

  // Get spending trend for last N months
  List<double> getSpendingTrend({int months = 6}) {
    final now = DateTime.now();
    final trend = <double>[];

    for (int i = months - 1; i >= 0; i--) {
      final targetDate = DateTime(now.year, now.month - i);
      final monthExpenses = _expenseDb.getAllExpenses().where((e) =>
          e.date.year == targetDate.year && e.date.month == targetDate.month);
      final total = monthExpenses.fold(0.0, (sum, e) => sum + e.amount);
      trend.add(total);
    }

    return trend;
  }

  // Get average daily spending
  double getAverageDailySpending() {
    final now = DateTime.now();
    final currentMonthExpenses = _expenseDb.getAllExpenses().where((e) =>
        e.date.year == now.year && e.date.month == now.month);
    final total = currentMonthExpenses.fold(0.0, (sum, e) => sum + e.amount);
    return total / now.day;
  }

  // Get total expenses for current month
  double getCurrentMonthTotal() {
    final now = DateTime.now();
    final currentMonthExpenses = _expenseDb.getAllExpenses().where((e) =>
        e.date.year == now.year && e.date.month == now.month);
    return currentMonthExpenses.fold(0.0, (sum, e) => sum + e.amount);
  }
}
