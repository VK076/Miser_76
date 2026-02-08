import 'package:hive/hive.dart';
import '../models/recurring_income.dart';
import '../models/income.dart';
import 'package:uuid/uuid.dart';

class RecurringIncomeDatabase {
  static const String _boxName = 'recurring_income';
  late Box<RecurringIncome> _box;
  final _uuid = const Uuid();

  Future<void> init() async {
    _box = await Hive.openBox<RecurringIncome>(_boxName);
  }

  // Add recurring income
  Future<void> addRecurringIncome(RecurringIncome recurringIncome) async {
    await _box.put(recurringIncome.id, recurringIncome);
  }

  // Update recurring income
  Future<void> updateRecurringIncome(RecurringIncome recurringIncome) async {
    await _box.put(recurringIncome.id, recurringIncome);
  }

  // Delete recurring income
  Future<void> deleteRecurringIncome(String id) async {
    await _box.delete(id);
  }

  // Get all recurring income
  List<RecurringIncome> getAllRecurringIncome() {
    return _box.values.toList();
  }

  // Get active recurring income
  List<RecurringIncome> getActiveRecurringIncome() {
    return _box.values.where((ri) => ri.isActive).toList();
  }

  // Get recurring income that should be created today
  List<RecurringIncome> getDueRecurringIncome() {
    return _box.values.where((ri) => ri.shouldCreateToday()).toList();
  }

  // Create income from recurring income
  Income createIncomeFromRecurring(RecurringIncome recurring) {
    return Income(
      id: _uuid.v4(),
      source: recurring.source,
      amount: recurring.amount,
      description: '${recurring.description} (Recurring)',
      date: DateTime.now(),
      isRecurring: true,
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

  // Get upcoming recurring income (next 7 days)
  List<Map<String, dynamic>> getUpcomingIncome() {
    final upcoming = <Map<String, dynamic>>[];
    final now = DateTime.now();
    final sevenDaysLater = now.add(const Duration(days: 7));

    for (var recurring in getActiveRecurringIncome()) {
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
