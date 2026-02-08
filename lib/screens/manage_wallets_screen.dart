import 'package:flutter/material.dart';
import '../models/wallet.dart';
import '../services/wallet_database.dart';
import '../services/expense_database.dart';
import '../services/income_database.dart';
import '../constants/app_constants.dart';
import 'package:uuid/uuid.dart';

class ManageWalletsScreen extends StatefulWidget {
  const ManageWalletsScreen({Key? key}) : super(key: key);

  @override
  State<ManageWalletsScreen> createState() => _ManageWalletsScreenState();
}

class _ManageWalletsScreenState extends State<ManageWalletsScreen> {
  final _walletDb = WalletDatabase();
  final _expenseDb = ExpenseDatabase(); // Assuming singleton or re-instantiated is fine as Hive boxes are singletons
  final _incomeDb = IncomeDatabase();
  List<Wallet> _wallets = [];

  double _calculateWalletBalance(Wallet wallet) {
    final expenses = _expenseDb.getExpensesByWallet(wallet.id);
    final income = _incomeDb.getIncomeByWallet(wallet.id);
    
    final totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final totalIncome = income.fold(0.0, (sum, i) => sum + i.amount);
    
    // wallet.balance is treated as "Initial Balance" (though currently UI sets it as 0 mostly)
    return wallet.balance + totalIncome - totalExpenses;
  }

  @override
  void initState() {
    super.initState();
    _loadWallets();
  }

  void _loadWallets() {
    setState(() {
      _wallets = _walletDb.getAllWallets();
    });
    
    // Seed default wallets if empty
    if (_wallets.isEmpty) {
      _seedDefaultWallets();
    }
  }

  Future<void> _seedDefaultWallets() async {
    final cash = Wallet(
      id: const Uuid().v4(),
      name: 'Cash',
      type: 'Cash',
      iconCode: Icons.money.codePoint,
      colorValue: Colors.green.value,
    );
    final bank = Wallet(
      id: const Uuid().v4(),
      name: 'Bank Account',
      type: 'Bank',
      iconCode: Icons.account_balance.codePoint,
      colorValue: Colors.blue.value,
    );

    await _walletDb.addWallet(cash);
    await _walletDb.addWallet(bank);
    _loadWallets();
  }

  Future<void> _showAddEditWalletDialog([Wallet? wallet]) async {
    final isEditing = wallet != null;
    final nameController = TextEditingController(text: wallet?.name);
    // Simple mock breakdown of types/icons for MVP
    String selectedType = wallet?.type ?? 'Cash';
    int selectedColor = wallet?.colorValue ?? Colors.blue.value;
    int selectedIcon = wallet?.iconCode ?? Icons.account_balance_wallet.codePoint;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Wallet' : 'Add Wallet'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Wallet Name'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                items: ['Cash', 'Bank', 'Credit Card', 'Other']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) => selectedType = val!,
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              // We can add Color/Icon pickers here, skipping for MVP speed
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;

              final newWallet = Wallet(
                id: wallet?.id ?? const Uuid().v4(),
                name: nameController.text,
                type: selectedType,
                iconCode: selectedType == 'Cash' 
                    ? Icons.money.codePoint 
                    : (selectedType == 'Credit Card' ? Icons.credit_card.codePoint : Icons.account_balance.codePoint),
                colorValue: selectedColor,
                balance: wallet?.balance ?? 0.0, // Preserve balance if editing
              );

              if (isEditing) {
                await _walletDb.updateWallet(newWallet);
              } else {
                await _walletDb.addWallet(newWallet);
              }
              
              if (mounted) Navigator.pop(context);
              _loadWallets();
            },
            child: Text(isEditing ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Wallets'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _wallets.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _wallets.length,
              itemBuilder: (context, index) {
                final wallet = _wallets[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: wallet.color.withOpacity(0.1),
                      child: Icon(wallet.icon, color: wallet.color),
                    ),
                    title: Text(wallet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(wallet.type),
                        const SizedBox(height: 4),
                        Text(
                          'Balance: \$${_calculateWalletBalance(wallet).toStringAsFixed(2)}',
                           style: TextStyle(
                             color: _calculateWalletBalance(wallet) >= 0 ? AppColors.success : AppColors.error,
                             fontWeight: FontWeight.bold,
                           ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                      ],
                      onSelected: (val) async {
                        if (val == 'edit') {
                          _showAddEditWalletDialog(wallet);
                        } else {
                          // Prevent deleting if it has transactions? For now just allow delete
                          await _walletDb.deleteWallet(wallet.id);
                          _loadWallets();
                        }
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditWalletDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
