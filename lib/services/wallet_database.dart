import 'package:hive_flutter/hive_flutter.dart';
import '../models/wallet.dart';

class WalletDatabase {
  static const String _boxName = 'wallets';

  static Future<void> initialize() async {
    await Hive.openBox<Wallet>(_boxName);
  }

  Box<Wallet> get _box => Hive.box<Wallet>(_boxName);

  List<Wallet> getAllWallets() {
    return _box.values.toList();
  }

  Future<void> addWallet(Wallet wallet) async {
    await _box.put(wallet.id, wallet);
  }

  Future<void> updateWallet(Wallet wallet) async {
    await _box.put(wallet.id, wallet);
  }

  Future<void> deleteWallet(String id) async {
    await _box.delete(id);
  }

  Wallet? getWalletById(String id) {
    return _box.get(id);
  }
}
