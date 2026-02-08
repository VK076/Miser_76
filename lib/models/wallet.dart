import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

@HiveType(typeId: 6) // Ensure unique typeId
class Wallet extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double balance;

  @HiveField(3)
  final String type; // 'Cash', 'Bank', 'Credit Card', 'Other'

  @HiveField(4)
  final int iconCode; // Store IconData codePoint

  @HiveField(5)
  final int colorValue; // Store Color value

  Wallet({
    required this.id,
    required this.name,
    this.balance = 0.0,
    required this.type,
    required this.iconCode,
    required this.colorValue,
  });

  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);
}
