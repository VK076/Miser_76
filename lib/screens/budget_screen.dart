import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/currency.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../services/budget_database.dart';
import '../services/expense_database.dart';
import 'package:uuid/uuid.dart';

class BudgetScreen extends StatefulWidget {
  final Currency selectedCurrency;

  const BudgetScreen({Key? key, required this.selectedCurrency}) : super(key: key);

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _budgetDb = BudgetDatabase();
  final _expenseDb = ExpenseDatabase();
  List<Budget> budgets = [];

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  void _loadBudgets() {
    setState(() {
      budgets = _budgetDb.getAllBudgets();
    });
  }

  void _showAddBudgetDialog({Budget? existingBudget}) {
    final isEditing = existingBudget != null;
    final amountController = TextEditingController(
      text: existingBudget?.amount.toString() ?? '',
    );
    String selectedCategory = existingBudget?.category ?? 'Food & Dining';
    String selectedPeriod = existingBudget?.period ?? 'month';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Budget' : 'Add Budget'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: CategoryManager.getCategoryNames().map((cat) {
                    final category = CategoryManager.getCategoryByName(cat);
                    return DropdownMenuItem(
                      value: cat,
                      child: Row(
                        children: [
                          Icon(category?.icon, size: 20, color: category?.color),
                          const SizedBox(width: 8),
                          Text(cat),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Amount TextField
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Budget Amount',
                    prefixText: '${widget.selectedCurrency.symbol} ',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Period Dropdown
                DropdownButtonFormField<String>(
                  value: selectedPeriod,
                  decoration: const InputDecoration(
                    labelText: 'Period',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'month', child: Text('Monthly')),
                    DropdownMenuItem(value: 'year', child: Text('Yearly')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedPeriod = value);
                    }
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

                final budget = Budget(
                  id: existingBudget?.id ?? const Uuid().v4(),
                  category: selectedCategory,
                  amount: amount,
                  period: selectedPeriod,
                  createdDate: existingBudget?.createdDate ?? DateTime.now(),
                );

                if (isEditing) {
                  await _budgetDb.updateBudget(budget);
                } else {
                  await _budgetDb.addBudget(budget);
                }

                _loadBudgets();
                if (mounted) Navigator.pop(context);
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteBudget(String id) async {
    await _budgetDb.deleteBudget(id);
    _loadBudgets();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget deleted')),
      );
    }
  }

  double _getSpentAmount(String category, String period) {
    final now = DateTime.now();
    final expenses = period == 'month'
        ? _expenseDb.getAllExpenses().where((e) =>
            e.category == category &&
            e.date.year == now.year &&
            e.date.month == now.month)
        : _expenseDb.getAllExpenses().where((e) =>
            e.category == category && e.date.year == now.year);
    
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Budgets'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: budgets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet_outlined,
                      size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No budgets yet',
                    style: TextStyle(fontSize: 18, color: textColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create your first budget',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              itemCount: budgets.length,
              itemBuilder: (context, index) {
                final budget = budgets[index];
                final spent = _getSpentAmount(budget.category, budget.period);
                final progress = (spent / budget.amount).clamp(0.0, 1.0);
                final isOverBudget = spent > budget.amount;
                final category = CategoryManager.getCategoryByName(budget.category);

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: category?.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                category?.icon,
                                color: category?.color,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    budget.category,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                  Text(
                                    budget.period == 'month' ? 'Monthly' : 'Yearly',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _showAddBudgetDialog(existingBudget: budget),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: AppColors.error,
                              onPressed: () => _deleteBudget(budget.id),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${widget.selectedCurrency.symbol}${spent.toStringAsFixed(2)} spent',
                              style: TextStyle(
                                fontSize: 14,
                                color: isOverBudget ? AppColors.error : Colors.grey,
                                fontWeight: isOverBudget ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            Text(
                              '${widget.selectedCurrency.symbol}${budget.amount.toStringAsFixed(2)} budget',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isOverBudget
                                  ? AppColors.error
                                  : progress > 0.8
                                      ? AppColors.warning
                                      : AppColors.success,
                            ),
                          ),
                        ),
                        if (isOverBudget)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber_rounded,
                                    size: 16, color: AppColors.error),
                                const SizedBox(width: 4),
                                Text(
                                  'Over budget by ${widget.selectedCurrency.symbol}${(spent - budget.amount).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddBudgetDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
