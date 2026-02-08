class Income {
  final String id;
  final double amount;
  final String source;
  final String description;
  final DateTime date;
  final bool isRecurring;
  final String? walletId;

  Income({
    required this.id,
    required this.amount,
    required this.source,
    required this.description,
    required this.date,
    this.isRecurring = false,
    this.walletId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'source': source,
      'description': description,
      'date': date.toIso8601String(),
      'isRecurring': isRecurring,
      'walletId': walletId,
    };
  }

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'] as String,
      amount: json['amount'] as double,
      source: json['source'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      isRecurring: json['isRecurring'] as bool? ?? false,
      walletId: json['walletId'] as String?,
    );
  }
}
