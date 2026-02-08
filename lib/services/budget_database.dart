import 'package:hive_flutter/hive_flutter.dart';
import '../models/budget.dart';

class BudgetDatabase {
  static const String _boxName = 'budgets';
  static Box<Budget>? _box;

  // Singleton pattern
  static final BudgetDatabase _instance = BudgetDatabase._internal();
  factory BudgetDatabase() => _instance;
  BudgetDatabase._internal();

  // Initialize the database
  static Future<void> initialize() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<Budget>(_boxName);
    }
  }

  // Get the box
  Box<Budget> get box {
    if (_box == null || !_box!.isOpen) {
      throw Exception('BudgetDatabase not initialized. Call initialize() first.');
    }
    return _box!;
  }

  // Create - Add a new budget
  Future<void> addBudget(Budget budget) async {
    await box.put(budget.id, budget);
  }

  // Read - Get all budgets
  List<Budget> getAllBudgets() {
    return box.values.toList();
  }

  // Read - Get budget by ID
  Budget? getBudgetById(String id) {
    return box.get(id);
  }

  // Read - Get budget by category
  Budget? getBudgetByCategory(String category) {
    try {
      return box.values.firstWhere((budget) => budget.category == category);
    } catch (e) {
      return null;
    }
  }

  // Update - Update an existing budget
  Future<void> updateBudget(Budget budget) async {
    await box.put(budget.id, budget);
  }

  // Delete - Remove a budget
  Future<void> deleteBudget(String id) async {
    await box.delete(id);
  }

  // Delete all budgets
  Future<void> deleteAllBudgets() async {
    await box.clear();
  }

  // Get monthly budgets
  List<Budget> getMonthlyBudgets() {
    return box.values.where((budget) => budget.period == 'month').toList();
  }

  // Get yearly budgets
  List<Budget> getYearlyBudgets() {
    return box.values.where((budget) => budget.period == 'year').toList();
  }

  // Get total count
  int get count => box.length;

  // Check if database is empty
  bool get isEmpty => box.isEmpty;
}
