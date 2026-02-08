import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';

class ExpenseDatabase {
  static const String _boxName = 'expenses';
  static Box<Expense>? _box;

  // Singleton pattern
  static final ExpenseDatabase _instance = ExpenseDatabase._internal();
  factory ExpenseDatabase() => _instance;
  ExpenseDatabase._internal();

  // Initialize the database
  static Future<void> initialize() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<Expense>(_boxName);
    }
  }

  // Get the box
  Box<Expense> get box {
    if (_box == null || !_box!.isOpen) {
      throw Exception('ExpenseDatabase not initialized. Call initialize() first.');
    }
    return _box!;
  }

  // Create - Add a new expense
  Future<void> addExpense(Expense expense) async {
    await box.put(expense.id, expense);
  }

  // Read - Get all expenses
  List<Expense> getAllExpenses() {
    return box.values.toList();
  }

  List<Expense> getExpensesByWallet(String walletId) {
    return _box!.values.where((e) => e.walletId == walletId).toList();
  }

  List<Expense> getExpensesByGoal(String goalId) {
    return _box!.values.where((e) => e.goalId == goalId).toList();
  }

  double getTotalSavedForGoal(String goalId) {
    return getExpensesByGoal(goalId).fold(0.0, (sum, e) => sum + e.amount);
  }

  // Read - Get expense by ID
  Expense? getExpenseById(String id) {
    return box.get(id);
  }

  // Update - Update an existing expense
  Future<void> updateExpense(Expense expense) async {
    await box.put(expense.id, expense);
  }

  // Delete - Remove an expense
  Future<void> deleteExpense(String id) async {
    await box.delete(id);
  }

  // Delete all expenses (for testing/reset)
  Future<void> deleteAllExpenses() async {
    await box.clear();
  }

  // Get expenses by date range
  List<Expense> getExpensesByDateRange(DateTime start, DateTime end) {
    return box.values.where((expense) {
      return expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
             expense.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Get expenses for current month
  List<Expense> getCurrentMonthExpenses() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return getExpensesByDateRange(startOfMonth, endOfMonth);
  }

  // Get expenses for current year
  List<Expense> getCurrentYearExpenses() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31);
    return getExpensesByDateRange(startOfYear, endOfYear);
  }

  // Get total count
  int get count => box.length;

  // Check if database is empty
  bool get isEmpty => box.isEmpty;
}
