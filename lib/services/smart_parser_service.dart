import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/wallet.dart';
import 'wallet_database.dart';

class SmartParserService {
  final WalletDatabase _walletDb;

  SmartParserService({WalletDatabase? walletDb})
      : _walletDb = walletDb ?? WalletDatabase();

  /// Parse a natural language string into a structured Expense object.
  /// 
  /// Patterns:
  /// - "{amount} {description}" -> "200 lunch"
  /// - "{description} {amount}" -> "lunch 200"
  /// - "{amount} {category} {description}" -> "200 food burger"
  /// 
  /// Returns a partial Expense object (ID is generated, but UI might want to override).
  Expense parse(String text) {
    if (text.isEmpty) {
      throw const FormatException("Text cannot be empty");
    }

    final lowerText = text.toLowerCase();
    
    // 1. Extract Amount
    final amountPattern = RegExp(r'[\$]?(\d+(\.\d{1,2})?)');
    final match = amountPattern.firstMatch(text);
    
    if (match == null) {
      throw const FormatException("Could not find a valid amount");
    }

    final amountStr = match.group(1)!; // The number part
    final amount = double.parse(amountStr);

    // 2. Extract Wallet (if specified)
    // We check if the text contains any wallet name "cash", "bank", "card" etc.
    String? walletId;
    final wallets = _walletDb.getAllWallets();
    for (var wallet in wallets) {
      if (lowerText.contains(wallet.name.toLowerCase())) {
        walletId = wallet.id;
        break; // Take the first match
      }
    }
    // Default to first wallet if none found
    if (walletId == null && wallets.isNotEmpty) {
      walletId = wallets.first.id;
    }

    // 3. Extract Category
    // We check text against category names. 
    // This is simple fuzzy matching.
    String category = 'Other';
    String? matchedCategoryName;
    
    final categoryNames = CategoryManager.getCategoryNames();
    for (var catName in categoryNames) {
      if (lowerText.contains(catName.toLowerCase())) {
        category = catName;
        matchedCategoryName = catName;
        break;
      }
    }
    
    // Heuristic: If no category found, try matching common keywords to categories
    if (matchedCategoryName == null) {
       category = _guessCategory(lowerText);
    }

    // 4. Extract Description
    // Remove amount, wallet, and category from text to get description
    String description = text;
    
    // Remove amount
    description = description.replaceAll(amountStr, '').trim();
    // Remove currency symbol if matched
    if (match.group(0)!.startsWith('\$')) {
       description = description.replaceAll('\$', '');
    }

    // Remove category if matched
    if (matchedCategoryName != null) {
      description = _removeWord(description, matchedCategoryName);
    }
    
    // Remove wallet if matched
    if (walletId != null) {
       final walletName = wallets.firstWhere((w) => w.id == walletId).name;
       description = _removeWord(description, walletName);
    }

    // Clean up
    description = description.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    // Default description if empty
    if (description.isEmpty) {
      description = category; 
    }

    return Expense(
      id: const Uuid().v4(),
      amount: amount,
      category: category,
      description: description,
      date: DateTime.now(), // TODO: Add date parsing (yesterday, etc)
      walletId: walletId,
    );
  }

  // Helper to remove a word (case insensitive) from a string
  String _removeWord(String text, String word) {
    return text.replaceAll(RegExp(word, caseSensitive: false), '').trim();
  }

  // Comprehensive keyword mapping for category guessing
  String _guessCategory(String text) {
    final Map<String, List<String>> keywords = {
      'Food & Dining': [
        // Meals
        'lunch', 'dinner', 'breakfast', 'brunch', 'snack',
        // Beverages
        'coffee', 'tea', 'juice', 'smoothie', 'shake', 'drink', 'soda', 'beer', 'wine',
        // Food items
        'burger', 'pizza', 'sandwich', 'pasta', 'rice', 'noodles', 'biryani',
        'chicken', 'fish', 'meat', 'salad', 'soup',
        // Places
        'restaurant', 'cafe', 'cafeteria', 'canteen', 'dhaba', 'hotel',
        'swiggy', 'zomato', 'ubereats', 'mcdonald', 'kfc', 'dominos', 'subway',
      ],
      'Groceries': [
        // Provisions
        'oil', 'ghee', 'butter', 'flour', 'atta', 'rice', 'dal', 'sugar', 'salt',
        'spices', 'masala', 'tea', 'coffee powder',
        // Dairy
        'milk', 'curd', 'yogurt', 'cheese', 'paneer',
        // Produce
        'vegetables', 'fruits', 'tomato', 'onion', 'potato', 'banana', 'apple',
        // Packaged
        'bread', 'biscuit', 'cookies', 'chips', 'noodles packet',
        // Stores
        'supermarket', 'grocery', 'kirana', 'dmart', 'reliance fresh', 'bigbasket',
      ],
      'Transport': [
        'taxi', 'uber', 'ola', 'rapido', 'auto', 'rickshaw',
        'bus', 'train', 'metro', 'flight', 'cab',
        'fuel', 'petrol', 'diesel', 'gas', 'cng',
        'parking', 'toll', 'ticket', 'pass',
      ],
      'Entertainment': [
        'movie', 'cinema', 'theatre', 'film', 'show',
        'netflix', 'prime', 'hotstar', 'spotify', 'youtube',
        'game', 'gaming', 'playstation', 'xbox',
        'concert', 'event', 'party', 'club',
      ],
      'Bills': [
        'electricity', 'electric', 'power', 'eb',
        'water', 'gas cylinder', 'lpg',
        'phone', 'mobile', 'recharge', 'prepaid', 'postpaid',
        'internet', 'wifi', 'broadband', 'airtel', 'jio', 'vi',
        'rent', 'maintenance', 'society',
      ],
      'Shopping': [
        'clothes', 'shirt', 'pant', 'dress', 'shoes', 'sandal',
        'amazon', 'flipkart', 'myntra', 'ajio',
        'electronics', 'mobile', 'laptop', 'headphone',
        'gift', 'shopping', 'mall',
      ],
      'Health': [
        'medicine', 'pharmacy', 'medical', 'doctor', 'hospital',
        'clinic', 'checkup', 'test', 'lab',
        'gym', 'fitness', 'yoga',
      ],
      'Education': [
        'book', 'course', 'class', 'tuition', 'coaching',
        'school', 'college', 'university', 'fees',
      ],
    };

    // Check each category's keywords
    for (var entry in keywords.entries) {
      for (var keyword in entry.value) {
        if (text.contains(keyword)) {
          return entry.key;
        }
      }
    }
    return 'Other';
  }
}
