import 'package:hive_flutter/hive_flutter.dart';
import '../models/income.dart';

class IncomeDatabase {
  static const String _boxName = 'income';
  static Box<Income>? _box;

  // Singleton pattern
  static final IncomeDatabase _instance = IncomeDatabase._internal();
  factory IncomeDatabase() => _instance;
  IncomeDatabase._internal();

  // Initialize the database
  static Future<void> initialize() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<Income>(_boxName);
    }
  }

  // Get the box
  Box<Income> get box {
    if (_box == null || !_box!.isOpen) {
      throw Exception('IncomeDatabase not initialized. Call initialize() first.');
    }
    return _box!;
  }

  // Create - Add a new income
  Future<void> addIncome(Income income) async {
    await box.put(income.id, income);
  }

  // Read - Get all income
  List<Income> getAllIncome() {
    return _box!.values.toList();
  }

  List<Income> getIncomeByWallet(String walletId) {
    return _box!.values.where((i) => i.walletId == walletId).toList();
  }

  // Read - Get income by ID
  Income? getIncomeById(String id) {
    return box.get(id);
  }

  // Update - Update an existing income
  Future<void> updateIncome(Income income) async {
    await box.put(income.id, income);
  }

  // Delete - Remove an income
  Future<void> deleteIncome(String id) async {
    await box.delete(id);
  }

  // Delete all income
  Future<void> deleteAllIncome() async {
    await box.clear();
  }

  // Get income by date range
  List<Income> getIncomeByDateRange(DateTime start, DateTime end) {
    return box.values.where((income) {
      return income.date.isAfter(start.subtract(const Duration(days: 1))) &&
             income.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Get income for current month
  List<Income> getCurrentMonthIncome() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return getIncomeByDateRange(startOfMonth, endOfMonth);
  }

  // Get income for current year
  List<Income> getCurrentYearIncome() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31);
    return getIncomeByDateRange(startOfYear, endOfYear);
  }

  // Calculate total income for a period
  double getTotalIncome(List<Income> incomeList) {
    return incomeList.fold(0.0, (sum, income) => sum + income.amount);
  }

  // Get income by source
  List<Income> getIncomeBySource(String source) {
    return box.values.where((income) => income.source == source).toList();
  }

  // Get all unique sources
  List<String> getAllSources() {
    return box.values.map((income) => income.source).toSet().toList();
  }

  // Get total count
  int get count => box.length;

  // Check if database is empty
  bool get isEmpty => box.isEmpty;
}
