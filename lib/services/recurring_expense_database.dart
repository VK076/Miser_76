import 'package:hive/hive.dart';
import '../models/recurring_expense.dart';
import '../models/expense.dart';
import 'package:uuid/uuid.dart';

class RecurringExpenseDatabase {
  static const String _boxName = 'recurring_expenses';
  late Box<RecurringExpense> _box;
  final _uuid = const Uuid();

  Future<void> init() async {
    _box = await Hive.openBox<RecurringExpense>(_boxName);
  }

  // Add recurring expense
  Future<void> addRecurringExpense(RecurringExpense recurringExpense) async {
    await _box.put(recurringExpense.id, recurringExpense);
  }

  // Update recurring expense
  Future<void> updateRecurringExpense(RecurringExpense recurringExpense) async {
    await _box.put(recurringExpense.id, recurringExpense);
  }

  // Delete recurring expense
  Future<void> deleteRecurringExpense(String id) async {
    await _box.delete(id);
  }

  // Get all recurring expenses
  List<RecurringExpense> getAllRecurringExpenses() {
    return _box.values.toList();
  }

  // Get active recurring expenses
  List<RecurringExpense> getActiveRecurringExpenses() {
    return _box.values.where((re) => re.isActive).toList();
  }

  // Get recurring expenses that should be created today
  List<RecurringExpense> getDueRecurringExpenses() {
    return _box.values.where((re) => re.shouldCreateToday()).toList();
  }

  // Create expense from recurring expense
  Expense createExpenseFromRecurring(RecurringExpense recurring) {
    return Expense(
      id: _uuid.v4(),
      category: recurring.category,
      amount: recurring.amount,
      description: '${recurring.description} (Recurring)',
      date: DateTime.now(),
    );
  }

  // Update last created date
  Future<void> updateLastCreated(String id) async {
    final recurring = _box.get(id);
    if (recurring != null) {
      final updated = recurring.copyWith(lastCreated: DateTime.now());
      await _box.put(id, updated);
    }
  }

  // Toggle active status
  Future<void> toggleActive(String id) async {
    final recurring = _box.get(id);
    if (recurring != null) {
      final updated = recurring.copyWith(isActive: !recurring.isActive);
      await _box.put(id, updated);
    }
  }

  // Get upcoming recurring expenses (next 7 days)
  List<Map<String, dynamic>> getUpcomingExpenses() {
    final upcoming = <Map<String, dynamic>>[];
    final now = DateTime.now();
    final sevenDaysLater = now.add(const Duration(days: 7));

    for (var recurring in getActiveRecurringExpenses()) {
      var nextDate = recurring.getNextDueDate();
      
      while (nextDate.isBefore(sevenDaysLater) || nextDate.isAtSameMomentAs(sevenDaysLater)) {
        if (nextDate.isAfter(now) || nextDate.isAtSameMomentAs(now)) {
          upcoming.add({
            'recurring': recurring,
            'dueDate': nextDate,
          });
        }
        
        // Calculate next occurrence
        switch (recurring.frequency) {
          case 'daily':
            nextDate = DateTime(nextDate.year, nextDate.month, nextDate.day + 1);
            break;
          case 'weekly':
            nextDate = DateTime(nextDate.year, nextDate.month, nextDate.day + 7);
            break;
          case 'monthly':
            nextDate = DateTime(nextDate.year, nextDate.month + 1, nextDate.day);
            break;
          case 'yearly':
            nextDate = DateTime(nextDate.year + 1, nextDate.month, nextDate.day);
            break;
        }
      }
    }

    upcoming.sort((a, b) => (a['dueDate'] as DateTime).compareTo(b['dueDate'] as DateTime));
    return upcoming;
  }
}
