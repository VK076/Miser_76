import 'package:uuid/uuid.dart';
import '../models/expense.dart';

class BankSmsParser {
  /// Parse bank SMS and return ParsedTransaction with confidence score
  ParsedTransaction parse(String message, String sender) {
    final result = ParsedTransaction(
      rawMessage: message,
      sender: sender,
    );

    try {
      // Extract amount
      final amount = _extractAmount(message);
      if (amount == null) {
        result.confidence = 0;
        result.error = 'No amount found';
        return result;
      }
      result.amount = amount;

      // Determine transaction type (debit/credit)
      final isDebit = _isDebitTransaction(message);
      if (!isDebit) {
        result.confidence = 0;
        result.error = 'Not a debit transaction';
        return result;
      }

      // Extract merchant/description
      result.merchant = _extractMerchant(message);
      
      // Extract account number (last 4 digits)
      result.accountLast4 = _extractAccount(message);

      // Map to category
      result.category = _mapToCategory(result.merchant);

      // Calculate confidence score
      result.confidence = _calculateConfidence(result, message);

      // Generate description
      result.description = _generateDescription(result);

      return result;
    } catch (e) {
      result.confidence = 0;
      result.error = 'Parse error: $e';
      return result;
    }
  }

  /// Extract amount from SMS (supports ₹, Rs, INR formats)
  double? _extractAmount(String message) {
    // Patterns: Rs.500, ₹500, INR 500, Rs 1,200.50
    final patterns = [
      RegExp(r'(?:Rs\.?|₹|INR)\s*([0-9,]+\.?[0-9]*)', caseSensitive: false),
      RegExp(r'([0-9,]+\.?[0-9]*)\s*(?:Rs|INR)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(message);
      if (match != null) {
        final amountStr = match.group(1)?.replaceAll(',', '');
        return double.tryParse(amountStr ?? '');
      }
    }

    return null;
  }

  /// Check if transaction is a debit (expense)
  bool _isDebitTransaction(String message) {
    final debitKeywords = [
      'debited',
      'debit',
      'spent',
      'withdrawn',
      'paid',
      'purchase',
      'transaction',
      'used',
    ];

    final messageLower = message.toLowerCase();
    return debitKeywords.any((keyword) => messageLower.contains(keyword));
  }

  /// Extract merchant/description from SMS
  String _extractMerchant(String message) {
    // Common patterns:
    // "at Amazon", "to John Doe", "for Coffee Shop", "on Swiggy"
    final patterns = [
      RegExp(r'(?:at|on|for|to)\s+([A-Za-z0-9\s]+?)(?:\s+on|\s+at|\s+for|\.|\s*$)', caseSensitive: false),
      RegExp(r'(?:merchant|vendor):\s*([A-Za-z0-9\s]+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(message);
      if (match != null) {
        return match.group(1)?.trim() ?? 'Unknown';
      }
    }

    // Fallback: Look for capitalized words after "for" or "at"
    final fallback = RegExp(r'(?:for|at)\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)', caseSensitive: true);
    final fallbackMatch = fallback.firstMatch(message);
    if (fallbackMatch != null) {
      return fallbackMatch.group(1)?.trim() ?? 'Unknown';
    }

    return 'Unknown';
  }

  /// Extract account number (last 4 digits)
  String? _extractAccount(String message) {
    // Patterns: "XX1234", "A/c XX1234", "Card XX5678"
    final pattern = RegExp(r'(?:A/c|Card|account)?\s*(?:XX|xx)?(\d{4})');
    final match = pattern.firstMatch(message);
    return match?.group(1);
  }

  /// Map merchant to category
  String _mapToCategory(String merchant) {
    final merchantLower = merchant.toLowerCase();

    final categoryMap = {
      'Food & Dining': ['swiggy', 'zomato', 'uber eats', 'restaurant', 'cafe', 'coffee', 'food', 'dominos', 'pizza', 'mcdonald', 'kfc', 'burger'],
      'Shopping': ['amazon', 'flipkart', 'myntra', 'ajio', 'shopping', 'mall', 'store', 'retail'],
      'Transport': ['uber', 'ola', 'rapido', 'taxi', 'metro', 'bus', 'petrol', 'fuel', 'parking'],
      'Entertainment': ['netflix', 'prime', 'hotstar', 'spotify', 'movie', 'cinema', 'theatre', 'bookmyshow'],
      'Utilities': ['electricity', 'water', 'gas', 'internet', 'broadband', 'mobile', 'recharge', 'bill'],
      'Health': ['pharmacy', 'hospital', 'doctor', 'clinic', 'medical', 'medicine', 'apollo', 'medplus'],
      'Rent': ['rent', 'maintenance', 'society'],
    };

    for (final entry in categoryMap.entries) {
      if (entry.value.any((keyword) => merchantLower.contains(keyword))) {
        return entry.key;
      }
    }

    return 'Other';
  }

  /// Calculate confidence score (0-100)
  int _calculateConfidence(ParsedTransaction result, String message) {
    int score = 0;

    // Amount found: +30
    if (result.amount != null && result.amount! > 0) {
      score += 30;
    }

    // Clear debit keywords: +20
    final debitKeywords = ['debited', 'spent', 'withdrawn'];
    if (debitKeywords.any((kw) => message.toLowerCase().contains(kw))) {
      score += 20;
    }

    // Merchant found and not "Unknown": +25
    if (result.merchant != 'Unknown') {
      score += 25;
    }

    // Category mapped (not "Other"): +15
    if (result.category != 'Other') {
      score += 15;
    }

    // Account number found: +10
    if (result.accountLast4 != null) {
      score += 10;
    }

    return score.clamp(0, 100);
  }

  /// Generate human-readable description
  String _generateDescription(ParsedTransaction result) {
    if (result.merchant != 'Unknown') {
      if (result.accountLast4 != null) {
        return 'Paid at ${result.merchant} (A/c XX${result.accountLast4})';
      }
      return 'Paid at ${result.merchant}';
    }

    if (result.accountLast4 != null) {
      return 'Transaction from A/c XX${result.accountLast4}';
    }

    return 'Bank transaction';
  }

  /// Check if sender is a known bank
  static bool isBankSender(String sender) {
    final bankKeywords = [
      'HDFC',
      'ICICI',
      'SBI',
      'AXIS',
      'KOTAK',
      'PAYTM',
      'PHONEPE',
      'GPAY',
      'AMAZON',
      'CITI',
      'HSBC',
      'INDUSIND',
      'YES BANK',
      'PNB',
      'BOB',
      'CANARA',
      'UNION',
      'IDBI',
      'FEDERAL',
      'RBL',
      'STANDARD',
      'DBS',
    ];

    final senderUpper = sender.toUpperCase();
    return bankKeywords.any((bank) => senderUpper.contains(bank));
  }
}

class ParsedTransaction {
  final String rawMessage;
  final String sender;
  double? amount;
  String merchant = 'Unknown';
  String category = 'Other';
  String? accountLast4;
  String description = '';
  int confidence = 0;
  String? error;

  ParsedTransaction({
    required this.rawMessage,
    required this.sender,
  });

  bool get isValid => confidence >= 30 && amount != null && amount! > 0;

  /// Convert to Expense object
  Expense toExpense() {
    return Expense(
      id: const Uuid().v4(),
      amount: amount ?? 0,
      category: category,
      description: description,
      date: DateTime.now(),
      note: 'Auto-captured from SMS (${confidence}% confident)',
    );
  }

  @override
  String toString() {
    return 'ParsedTransaction(amount: $amount, merchant: $merchant, category: $category, confidence: $confidence%)';
  }
}
