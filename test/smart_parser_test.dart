import 'package:flutter_test/flutter_test.dart';
import 'package:finance_app/services/smart_parser_service.dart';
import 'package:finance_app/services/wallet_database.dart';
import 'package:hive/hive.dart';
import 'package:finance_app/models/wallet.dart';

// Fake WalletDatabase for testing
class FakeWalletDatabase implements WalletDatabase {
  @override
  List<Wallet> getAllWallets() {
    return [
      Wallet(id: 'w1', name: 'Cash', balance: 0, type: 'cash', colorValue: 0, iconCode: 0),
      Wallet(id: 'w2', name: 'Bank', balance: 0, type: 'bank', colorValue: 0, iconCode: 0),
    ];
  }
  
  // Stubs for other methods
  @override
  Future<void> addWallet(Wallet wallet) async {}
  @override
  Future<void> deleteWallet(String id) async {}
  @override
  Wallet? getWalletById(String id) => null;
  @override
  Future<void> updateWallet(Wallet wallet) async {}
  
  @override
  // TODO: implement _box
  Box<Wallet> get _box => throw UnimplementedError();
}

void main() {
  group('SmartParserService', () {
    late SmartParserService parser;

    setUp(() {
      parser = SmartParserService(walletDb: FakeWalletDatabase());
    });

    test('parses simple amount and description', () {
      final result = parser.parse('200 lunch');
      expect(result.amount, 200.0);
      expect(result.description, 'lunch');
      // Category might be 'Food & Dining' based on keyword 'lunch'
      expect(result.category, 'Food & Dining');
    });

    test('parses description then amount', () {
      final result = parser.parse('lunch 200');
      expect(result.amount, 200.0);
      expect(result.description, 'lunch');
    });

    test('parses fractional amount', () {
      final result = parser.parse('20.50 taxi');
      expect(result.amount, 20.50);
      expect(result.category, 'Transport');
    });
    
    test('parses explicit category', () {
      final result = parser.parse('500 Transport Bus Ticket');
      expect(result.amount, 500.0);
      expect(result.category, 'Transport');
      expect(result.description, 'Bus Ticket');
    });
  });
}
