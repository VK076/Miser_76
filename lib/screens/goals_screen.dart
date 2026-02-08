import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../models/wallet.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../services/goal_database.dart';
import '../services/wallet_database.dart';
import '../services/expense_database.dart';
import '../constants/app_constants.dart';
import 'package:uuid/uuid.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({Key? key}) : super(key: key);

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _goalDb = GoalDatabase();
  final _walletDb = WalletDatabase();
  final _expenseDb = ExpenseDatabase();
  
  List<Goal> _goals = [];
  List<Wallet> _wallets = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _goals = _goalDb.getAllGoals();
      _wallets = _walletDb.getAllWallets();
    });
  }

  double _calculateProgress(Goal goal) {
    // Current Saved = Initial manual entry + sum of all expenses linked to this goal
    final savedFromExpenses = _expenseDb.getTotalSavedForGoal(goal.id);
    return goal.initialSavedAmount + savedFromExpenses;
  }

  void _showAddEditGoalDialog([Goal? goal]) {
    final isEditing = goal != null;
    final nameController = TextEditingController(text: goal?.name);
    final targetController = TextEditingController(text: goal?.targetAmount.toString());
    final initialController = TextEditingController(text: goal?.initialSavedAmount.toString() ?? '0');
    DateTime? deadline = goal?.deadline;
    int selectedIcon = goal?.iconCode ?? Icons.savings.codePoint;
    int selectedColor = goal?.colorValue ?? Colors.blue.value;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Edit Goal' : 'New Savings Goal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Goal Name'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Target Amount'),
                ),
                if (!isEditing) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: initialController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Initial Savings (Already Saved)',
                      helperText: 'For money already saved outside the app or before tracking',
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(deadline == null ? 'Set Deadline' : 'Deadline: ${deadline!.day}/${deadline!.month}/${deadline!.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: deadline ?? DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                    );
                    if (date != null) {
                      setState(() => deadline = date);
                    }
                  },
                ),
                // Color/Icon picking can be added here
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
                final name = nameController.text.trim();
                final target = double.tryParse(targetController.text) ?? 0.0;
                final initial = double.tryParse(initialController.text) ?? 0.0;
                
                if (name.isEmpty || target <= 0) return;

                final newGoal = Goal(
                  id: goal?.id ?? const Uuid().v4(),
                  name: name,
                  targetAmount: target,
                  initialSavedAmount: isEditing ? goal!.initialSavedAmount : initial,
                  deadline: deadline,
                  iconCode: selectedIcon,
                  colorValue: selectedColor,
                  isCompleted: goal?.isCompleted ?? false,
                );

                if (isEditing) {
                  await _goalDb.updateGoal(newGoal);
                } else {
                  await _goalDb.addGoal(newGoal);
                }
                
                _loadData();
                Navigator.pop(context);
              },
              child: Text(isEditing ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddContributionDialog(Goal goal) {
    if (_wallets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Create a wallet first!')));
      return;
    }
    
    final amountController = TextEditingController();
    String selectedWalletId = _wallets.first.id;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add Funds to ${goal.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedWalletId,
                decoration: const InputDecoration(labelText: 'From Wallet'),
                items: _wallets.map((w) => DropdownMenuItem(value: w.id, child: Text(w.name))).toList(),
                onChanged: (val) => setState(() => selectedWalletId = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text) ?? 0.0;
                if (amount <= 0) return;

                // Create an Expense linked to this Goal
                final contribution = Expense(
                  id: const Uuid().v4(),
                  amount: amount,
                  category: 'Savings', // System category or special one?
                  description: 'Contribution to ${goal.name}',
                  date: DateTime.now(),
                  walletId: selectedWalletId,
                  goalId: goal.id,
                );

                await _expenseDb.addExpense(contribution);
                
                // Also check if goal is completed
                final currentTotal = _calculateProgress(goal);
                if (currentTotal + amount >= goal.targetAmount && !goal.isCompleted) {
                  // Mark as completed? Or just show celebration. 
                  // Updating isCompleted requires model update.
                  // For now, let's just save.
                }

                _loadData();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contribution added!')));
              },
              child: const Text('Add Funds'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primary,
      ),
      body: _goals.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.flag, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No goals set yet'),
                  TextButton(onPressed: () => _showAddEditGoalDialog(), child: const Text('Create Goal')),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _goals.length,
              itemBuilder: (context, index) {
                final goal = _goals[index];
                final progress = _calculateProgress(goal);
                final ratio = (progress / goal.targetAmount).clamp(0.0, 1.0);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Color(goal.colorValue).withOpacity(0.2),
                                  child: Icon(goal.icon, color: Color(goal.colorValue)),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(goal.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    if (goal.deadline != null)
                                      Text('Target: ${goal.deadline!.year}-${goal.deadline!.month}-${goal.deadline!.day}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                            PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                              ],
                              onSelected: (val) async {
                                if (val == 'edit') {
                                  _showAddEditGoalDialog(goal);
                                } else {
                                  await _goalDb.deleteGoal(goal.id);
                                  _loadData();
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: ratio,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation(Color(goal.colorValue)),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('\$${progress.toStringAsFixed(0)} / \$${goal.targetAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('${(ratio * 100).toStringAsFixed(1)}%'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _showAddContributionDialog(goal),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Funds'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditGoalDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
