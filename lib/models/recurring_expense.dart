class RecurringExpense {
  final String id;
  final String category;
  final double amount;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final String frequency; // 'daily', 'weekly', 'monthly', 'yearly'
  final DateTime lastCreated;
  final bool isActive;
  final String? walletId;

  RecurringExpense({
    required this.id,
    required this.category,
    required this.amount,
    required this.description,
    required this.startDate,
    this.endDate,
    required this.frequency,
    required this.lastCreated,
    this.isActive = true,
    this.walletId,
  });

  RecurringExpense copyWith({
    String? id,
    String? category,
    double? amount,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? frequency,
    DateTime? lastCreated,
    bool? isActive,
    String? walletId,
  }) {
    return RecurringExpense(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      frequency: frequency ?? this.frequency,
      lastCreated: lastCreated ?? this.lastCreated,
      isActive: isActive ?? this.isActive,
      walletId: walletId ?? this.walletId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'frequency': frequency,
      'lastCreated': lastCreated.toIso8601String(),
      'isActive': isActive,
      'walletId': walletId,
    };
  }

  factory RecurringExpense.fromJson(Map<String, dynamic> json) {
    return RecurringExpense(
      id: json['id'],
      category: json['category'],
      amount: json['amount'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      frequency: json['frequency'],
      lastCreated: DateTime.parse(json['lastCreated']),
      isActive: json['isActive'] ?? true,
      walletId: json['walletId'],
    );
  }

  DateTime getNextDueDate() {
    final now = DateTime.now();
    var nextDate = lastCreated;

    while (nextDate.isBefore(now)) {
      switch (frequency) {
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

    return nextDate;
  }

  bool shouldCreateToday() {
    final now = DateTime.now();
    final nextDue = getNextDueDate();
    
    return isActive && 
           now.year == nextDue.year && 
           now.month == nextDue.month && 
           now.day == nextDue.day &&
           (endDate == null || now.isBefore(endDate!));
  }
}
