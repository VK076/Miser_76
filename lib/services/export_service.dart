import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../models/budget.dart';
import '../constants/currency.dart';

class ExportService {
  Future<String> exportExpensesToCSV(
    List<Expense> expenses,
    Currency currency,
  ) async {
    final buffer = StringBuffer();
    buffer.writeln('Date,Category,Amount,Description,Currency');
    
    for (var expense in expenses) {
      final date = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}-${expense.date.day.toString().padLeft(2, '0')}';
      final category = _escapeCsv(expense.category);
      final amount = expense.amount.toStringAsFixed(2);
      final description = _escapeCsv(expense.description);
      buffer.writeln('$date,$category,$amount,$description,${currency.code}');
    }
    
    return buffer.toString();
  }

  Future<String> exportIncomeToCSV(
    List<Income> incomeList,
    Currency currency,
  ) async {
    final buffer = StringBuffer();
    buffer.writeln('Date,Source,Amount,Description,Recurring,Currency');
    
    for (var income in incomeList) {
      final date = '${income.date.year}-${income.date.month.toString().padLeft(2, '0')}-${income.date.day.toString().padLeft(2, '0')}';
      final source = _escapeCsv(income.source);
      final amount = income.amount.toStringAsFixed(2);
      final description = _escapeCsv(income.description);
      final recurring = income.isRecurring ? 'Yes' : 'No';
      buffer.writeln('$date,$source,$amount,$description,$recurring,${currency.code}');
    }
    
    return buffer.toString();
  }

  Future<String> exportBudgetsToCSV(
    List<Budget> budgets,
    Map<String, double> spending,
    Currency currency,
  ) async {
    final buffer = StringBuffer();
    buffer.writeln('Category,Budget,Spent,Remaining,Percentage,Period,Currency');
    
    for (var budget in budgets) {
      final category = _escapeCsv(budget.category);
      final budgetAmount = budget.amount.toStringAsFixed(2);
      final spent = (spending[budget.category] ?? 0).toStringAsFixed(2);
      final remaining = (budget.amount - (spending[budget.category] ?? 0)).toStringAsFixed(2);
      final percentage = ((spending[budget.category] ?? 0) / budget.amount * 100).toStringAsFixed(1);
      final period = budget.period;
      buffer.writeln('$category,$budgetAmount,$spent,$remaining,$percentage%,$period,${currency.code}');
    }
    
    return buffer.toString();
  }

  Future<String> exportCombinedReport(
    List<Expense> expenses,
    List<Income> incomeList,
    List<Budget> budgets,
    Map<String, double> spending,
    Currency currency,
  ) async {
    final buffer = StringBuffer();
    
    buffer.writeln('=== FINANCIAL REPORT ===');
    buffer.writeln('Currency: ${currency.name} (${currency.code})');
    buffer.writeln('');
    
    final totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final totalIncome = incomeList.fold(0.0, (sum, i) => sum + i.amount);
    final netBalance = totalIncome - totalExpenses;
    
    buffer.writeln('=== SUMMARY ===');
    buffer.writeln('Total Income: ${currency.symbol}${totalIncome.toStringAsFixed(2)}');
    buffer.writeln('Total Expenses: ${currency.symbol}${totalExpenses.toStringAsFixed(2)}');
    buffer.writeln('Net Balance: ${currency.symbol}${netBalance.toStringAsFixed(2)}');
    buffer.writeln('');
    
    buffer.writeln('=== EXPENSES ===');
    buffer.writeln('Date,Category,Amount,Description');
    for (var expense in expenses) {
      final date = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}-${expense.date.day.toString().padLeft(2, '0')}';
      final category = _escapeCsv(expense.category);
      final amount = '${currency.symbol}${expense.amount.toStringAsFixed(2)}';
      final description = _escapeCsv(expense.description);
      buffer.writeln('$date,$category,$amount,$description');
    }
    buffer.writeln('');
    
    buffer.writeln('=== INCOME ===');
    buffer.writeln('Date,Source,Amount,Description');
    for (var income in incomeList) {
      final date = '${income.date.year}-${income.date.month.toString().padLeft(2, '0')}-${income.date.day.toString().padLeft(2, '0')}';
      final source = _escapeCsv(income.source);
      final amount = '${currency.symbol}${income.amount.toStringAsFixed(2)}';
      final description = _escapeCsv(income.description);
      buffer.writeln('$date,$source,$amount,$description');
    }
    buffer.writeln('');
    
    buffer.writeln('=== BUDGETS ===');
    buffer.writeln('Category,Budget,Spent,Remaining,Status');
    for (var budget in budgets) {
      final category = _escapeCsv(budget.category);
      final budgetAmount = '${currency.symbol}${budget.amount.toStringAsFixed(2)}';
      final spent = '${currency.symbol}${(spending[budget.category] ?? 0).toStringAsFixed(2)}';
      final remaining = '${currency.symbol}${(budget.amount - (spending[budget.category] ?? 0)).toStringAsFixed(2)}';
      final status = (spending[budget.category] ?? 0) > budget.amount ? 'Over Budget' : 'On Track';
      buffer.writeln('$category,$budgetAmount,$spent,$remaining,$status');
    }
    
    return buffer.toString();
  }

  Future<void> shareCSV(String csvContent, String filename) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(csvContent);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Financial Report',
      );
    } catch (e) {
      throw Exception('Failed to share file: $e');
    }
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
