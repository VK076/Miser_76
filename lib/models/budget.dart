class Budget {
  final String id;
  final String category;
  final double amount;
  final String period; // 'month' or 'year'
  final DateTime createdDate;

  Budget({
    required this.id,
    required this.category,
    required this.amount,
    required this.period,
    required this.createdDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'period': period,
      'createdDate': createdDate.toIso8601String(),
    };
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as String,
      category: json['category'] as String,
      amount: json['amount'] as double,
      period: json['period'] as String,
      createdDate: DateTime.parse(json['createdDate'] as String),
    );
  }
}
