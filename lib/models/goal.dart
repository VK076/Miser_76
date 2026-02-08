import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

@HiveType(typeId: 7) // Ensure unique typeId
class Goal extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double targetAmount;

  @HiveField(3)
  final double initialSavedAmount;

  @HiveField(4)
  final DateTime? deadline;

  @HiveField(5)
  final int iconCode;

  @HiveField(6)
  final int colorValue;

  @HiveField(7)
  final bool isCompleted;

  Goal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.initialSavedAmount = 0.0,
    this.deadline,
    required this.iconCode,
    required this.colorValue,
    this.isCompleted = false,
  });

   IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');
   Color get color => Color(colorValue);

   // Progress calculation needs access to expenses. 
   // We will handle dynamic calculation in the UI or Service layer.
   // This getter now only reflects initial amount if used directly, 
   // but typically we should pass the full saved amount to UI.
   double get progress => targetAmount > 0 ? (initialSavedAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
}
