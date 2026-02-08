import 'dart:io';
import 'package:csv/csv.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../services/wallet_database.dart';

class CsvImportService {
  final WalletDatabase _walletDb;

  CsvImportService({WalletDatabase? walletDb}) 
      : _walletDb = walletDb ?? WalletDatabase();

  /// Parse CSV file and return list of expenses
  /// Expected format: date,amount,category,description,wallet
  Future<CsvImportResult> importFromFile(String filePath) async {
    try {
      final file = File(filePath);
      final csvString = await file.readAsString();
      
      return await importFromString(csvString);
    } catch (e) {
      return CsvImportResult(
        expenses: [],
        errors: ['Failed to read file: $e'],
      );
    }
  }

  Future<CsvImportResult> importFromString(String csvString) async {
    final List<Expense> expenses = [];
    final List<String> errors = [];
    
    try {
      // Parse CSV
      final List<List<dynamic>> rows = const CsvToListConverter().convert(csvString);
      
      if (rows.isEmpty) {
        return CsvImportResult(expenses: [], errors: ['CSV file is empty']);
      }

      // Get header row
      final headers = rows[0].map((e) => e.toString().toLowerCase().trim()).toList();
      
      // Validate required columns
      if (!headers.contains('amount')) {
        return CsvImportResult(expenses: [], errors: ['Missing required column: amount']);
      }

      // Get all wallets for mapping
      final wallets = await _walletDb.getAllWallets();
      
      // Process data rows
      for (int i = 1; i < rows.length; i++) {
        try {
          final row = rows[i];
          if (row.isEmpty) continue;
          
          // Create map from headers
          final Map<String, dynamic> rowData = {};
          for (int j = 0; j < headers.length && j < row.length; j++) {
            rowData[headers[j]] = row[j];
          }
          
          // Parse amount (required)
          final amountStr = rowData['amount']?.toString() ?? '';
          final amount = double.tryParse(amountStr.replaceAll(',', ''));
          
          if (amount == null || amount <= 0) {
            errors.add('Row ${i + 1}: Invalid amount "$amountStr"');
            continue;
          }
          
          // Parse date (optional, defaults to now)
          DateTime date = DateTime.now();
          if (rowData.containsKey('date') && rowData['date'] != null) {
            final dateStr = rowData['date'].toString().trim();
            date = _parseDate(dateStr) ?? DateTime.now();
          }
          
          // Parse category (optional, defaults to 'Other')
          String category = 'Other';
          if (rowData.containsKey('category') && rowData['category'] != null) {
            final categoryStr = rowData['category'].toString().trim();
            category = _matchCategory(categoryStr);
          }
          
          // Parse description (optional)
          final description = rowData['description']?.toString().trim() ?? '';
          
          // Parse wallet (optional)
          String? walletId;
          if (rowData.containsKey('wallet') && rowData['wallet'] != null) {
            final walletStr = rowData['wallet'].toString().trim();
            walletId = _matchWallet(walletStr, wallets);
          }
          
          // Create expense
          expenses.add(Expense(
            id: const Uuid().v4(),
            amount: amount,
            category: category,
            description: description,
            date: date,
            walletId: walletId,
          ));
          
        } catch (e) {
          errors.add('Row ${i + 1}: $e');
        }
      }
      
      return CsvImportResult(expenses: expenses, errors: errors);
      
    } catch (e) {
      return CsvImportResult(
        expenses: [],
        errors: ['Failed to parse CSV: $e'],
      );
    }
  }

  /// Try to parse various date formats
  DateTime? _parseDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    
    // Try ISO format first
    try {
      return DateTime.parse(dateStr);
    } catch (_) {}
    
    // Try common formats
    final formats = [
      RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$'), // dd/MM/yyyy or MM/dd/yyyy
      RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$'), // yyyy-MM-dd
    ];
    
    for (final format in formats) {
      final match = format.firstMatch(dateStr);
      if (match != null) {
        try {
          // Assume dd/MM/yyyy for slash format
          if (dateStr.contains('/')) {
            final parts = dateStr.split('/');
            return DateTime(
              int.parse(parts[2]), // year
              int.parse(parts[1]), // month
              int.parse(parts[0]), // day
            );
          }
        } catch (_) {}
      }
    }
    
    return null;
  }

  /// Match category name to existing categories
  String _matchCategory(String input) {
    final categories = CategoryManager.allCategories;
    final inputLower = input.toLowerCase();
    
    // Exact match
    for (final cat in categories) {
      if (cat.name.toLowerCase() == inputLower) {
        return cat.name;
      }
    }
    
    // Partial match
    for (final cat in categories) {
      if (cat.name.toLowerCase().contains(inputLower) ||
          inputLower.contains(cat.name.toLowerCase())) {
        return cat.name;
      }
    }
    
    return 'Other';
  }

  /// Match wallet name to existing wallets
  String? _matchWallet(String input, List wallets) {
    final inputLower = input.toLowerCase();
    
    for (final wallet in wallets) {
      if (wallet.name.toLowerCase() == inputLower) {
        return wallet.id;
      }
    }
    
    // Partial match
    for (final wallet in wallets) {
      if (wallet.name.toLowerCase().contains(inputLower) ||
          inputLower.contains(wallet.name.toLowerCase())) {
        return wallet.id;
      }
    }
    
    return null;
  }
}

class CsvImportResult {
  final List<Expense> expenses;
  final List<String> errors;

  CsvImportResult({
    required this.expenses,
    required this.errors,
  });

  bool get hasErrors => errors.isNotEmpty;
  int get successCount => expenses.length;
}
