class Expense {
    final String id;
    final double amount;
    final String category;
    final String description;
    final DateTime date;
    final bool isAvoidable;
    final String? walletId;
    final String? goalId;

    // Constructor
    Expense({
        required this.id,
        required this.amount,
        required this.category,
        required this.description,
        required this.date,
        this.isAvoidable = false,
        this.walletId,
        this.goalId,
    });

    // Method to convert Expense object to Json (for database storage)
    Map<String, dynamic> toJson() {
        return {
            'id': id,
            'amount': amount,
            'category': category,
            'description': description,
            'date': date.toIso8601String(),
            'isAvoidable': isAvoidable,
            'walletId': walletId,
        };
    }

    // This method is used to create an Expense object from Json data
    factory Expense.fromJson(Map<String, dynamic> json) {
        return Expense(
            id: json['id'] as String,
            amount: json['amount'] as double,
            category: json['category'] as String,
            description: json['description'] as String,
            date: DateTime.parse(json['date'] as String),
            isAvoidable: json['isAvoidable'] as bool? ?? true,
            walletId: json['walletId'] as String?,
        );
    }
}