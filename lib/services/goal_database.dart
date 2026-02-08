import 'package:hive_flutter/hive_flutter.dart';
import '../models/goal.dart';

class GoalDatabase {
  static const String _boxName = 'goals';

  static Future<void> initialize() async {
    await Hive.openBox<Goal>(_boxName);
  }

  Box<Goal> get _box => Hive.box<Goal>(_boxName);

  List<Goal> getAllGoals() {
    return _box.values.toList();
  }

  Future<void> addGoal(Goal goal) async {
    await _box.put(goal.id, goal);
  }

  Future<void> updateGoal(Goal goal) async {
    await _box.put(goal.id, goal);
  }

  Future<void> deleteGoal(String id) async {
    await _box.delete(id);
  }
}
