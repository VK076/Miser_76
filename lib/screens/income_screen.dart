import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/currency.dart';
import '../models/income.dart';
import '../services/income_database.dart';
import '../services/wallet_database.dart';
import '../models/wallet.dart';
import 'package:uuid/uuid.dart';

class IncomeScreen extends StatefulWidget {
  final Currency selectedCurrency;

  const IncomeScreen({Key? key, required this.selectedCurrency}) : super(key: key);

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final _incomeDb = IncomeDatabase();
  List<Income> incomeList = [];

  final List<String> incomeSources = [
    'Salary',
    'Freelance',
    'Business',
    'Investment',
    'Gift',
    'Other',
  ];

  final _walletDb = WalletDatabase();
  List<Wallet> _wallets = [];

  @override
  void initState() {
    super.initState();
    _loadIncome();
    _loadWallets();
  }

  void _loadWallets() {
    setState(() {
      _wallets = _walletDb.getAllWallets();
    });
  }

  void _loadIncome() {
    setState(() {
      incomeList = _incomeDb.getAllIncome();
      incomeList.sort((a, b) => b.date.compareTo(a.date)); // Newest first
    });
  }

  void _showAddIncomeDialog({Income? existingIncome}) {
    final isEditing = existingIncome != null;
    final amountController = TextEditingController(
      text: existingIncome?.amount.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: existingIncome?.description ?? '',
    );
    String selectedSource = existingIncome?.source ?? 'Salary';
    DateTime selectedDate = existingIncome?.date ?? DateTime.now();
    bool isRecurring = existingIncome?.isRecurring ?? false;
    String? selectedWalletId = existingIncome?.walletId;
    
    // Default wallet if adding new and wallets available
    if (!isEditing && selectedWalletId == null && _wallets.isNotEmpty) {
      selectedWalletId = _wallets.first.id;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Income' : 'Add Income'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixText: '${widget.selectedCurrency.symbol} ',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedSource,
                  decoration: const InputDecoration(
                    labelText: 'Source',
                    border: OutlineInputBorder(),
                  ),
                  items: incomeSources.map((source) {
                    return DropdownMenuItem(value: source, child: Text(source));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedSource = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // Wallet Dropdown
                DropdownButtonFormField<String>(
                  value: selectedWalletId,
                  decoration: const InputDecoration(
                    labelText: 'Wallet',
                    border: OutlineInputBorder(),
                  ),
                  items: _wallets.map((wallet) {
                    return DropdownMenuItem(value: wallet.id, child: Text(wallet.name));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedWalletId = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date'),
                  subtitle: Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setDialogState(() => selectedDate = date);
                    }
                  },
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Recurring Income'),
                  value: isRecurring,
                  onChanged: (value) {
                    setDialogState(() => isRecurring = value ?? false);
                  },
                ),
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
                final amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid amount')),
                  );
                  return;
                }

                if (descriptionController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a description')),
                  );
                  return;
                }

                final income = Income(
                  id: existingIncome?.id ?? const Uuid().v4(),
                  amount: amount,
                  source: selectedSource,
                  description: descriptionController.text.trim(),
                  date: selectedDate,
                  isRecurring: isRecurring,
                  walletId: selectedWalletId,
                );

                if (isEditing) {
                  await _incomeDb.updateIncome(income);
                } else {
                  await _incomeDb.addIncome(income);
                }

                _loadIncome();
                if (mounted) Navigator.pop(context);
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteIncome(String id) async {
    await _incomeDb.deleteIncome(id);
    _loadIncome();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Income deleted')),
      );
    }
  }

  IconData _getSourceIcon(String source) {
    switch (source) {
      case 'Salary':
        return Icons.work;
      case 'Freelance':
        return Icons.laptop;
      case 'Business':
        return Icons.business;
      case 'Investment':
        return Icons.trending_up;
      case 'Gift':
        return Icons.card_giftcard;
      default:
        return Icons.attach_money;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    final totalIncome = _incomeDb.getTotalIncome(incomeList);
    final monthlyIncome = _incomeDb.getTotalIncome(_incomeDb.getCurrentMonthIncome());

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Income'),
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Stats Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'This Month',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.selectedCurrency.symbol}${monthlyIncome.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total: ${widget.selectedCurrency.symbol}${totalIncome.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          // Income List
          Expanded(
            child: incomeList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance_wallet_outlined,
                            size: 80, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No income recorded',
                          style: TextStyle(fontSize: 18, color: textColor),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap + to add your first income',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: incomeList.length,
                    itemBuilder: (context, index) {
                      final income = incomeList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.success.withOpacity(0.1),
                            child: Icon(
                              _getSourceIcon(income.source),
                              color: AppColors.success,
                            ),
                          ),
                          title: Text(
                            income.description,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${income.source} • ${income.date.day}/${income.date.month}/${income.date.year}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${widget.selectedCurrency.symbol}${income.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                              PopupMenuButton(
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: AppColors.error),
                                        SizedBox(width: 8),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showAddIncomeDialog(existingIncome: income);
                                  } else if (value == 'delete') {
                                    _deleteIncome(income.id);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.success,
        onPressed: () => _showAddIncomeDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
