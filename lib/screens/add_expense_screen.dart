import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/wallet.dart';
import '../services/wallet_database.dart';
import 'package:uuid/uuid.dart';

/// Screen to add or edit an expense
class AddExpenseScreen extends StatefulWidget {
  final Function(Expense) onExpenseAdded;
final Expense? expenseToEdit;

  const AddExpenseScreen({
    Key? key,
    required this.onExpenseAdded,
    this.expenseToEdit,
  }) : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  // Controllers for text inputs
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  // Variables to track selected values
  String _selectedCategory = 'Food & Dining';
  DateTime _selectedDate = DateTime.now();
  bool _isAvoidable = true;
  String? _selectedWalletId;

  // List of categories from CategoryManager
  late List<String> categories = CategoryManager.getCategoryNames();
  
  // Wallet Data
  final _walletDb = WalletDatabase();
  List<Wallet> _wallets = [];


  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _descriptionController = TextEditingController();
    _fetchWallets();

    // If editing, populate fields with existing expense data
    if (widget.expenseToEdit != null) {
      final expense = widget.expenseToEdit!;
      _amountController.text = expense.amount.toString();
      _descriptionController.text = expense.description;
      _selectedCategory = expense.category;
      _selectedDate = expense.date;
      _isAvoidable = expense.isAvoidable;
      _selectedWalletId = expense.walletId;
    }
  }

  void _fetchWallets() {
    setState(() {
      _wallets = _walletDb.getAllWallets();
      if (_wallets.isNotEmpty && _selectedWalletId == null) {
        // Default to first wallet (Cash) if adding new
        _selectedWalletId = _wallets.first.id;
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Handle saving the expense
  void _handleSaveExpense() {
    // Step 1: Validate inputs
    final amount = _amountController.text.trim();
    final description = _descriptionController.text.trim();

    // Check if amount is empty
    if (amount.isEmpty) {
      _showSnackBar('Please enter an amount', isError: true);
      return;
    }

    // Check if description is empty
    if (description.isEmpty) {
      _showSnackBar('Please enter a description', isError: true);
      return;
    }

    // Try to convert amount to double
    double? parsedAmount = double.tryParse(amount);
    if (parsedAmount == null) {
      _showSnackBar('Please enter a valid amount', isError: true);
      return;
    }

    // Check if amount is positive
    if (parsedAmount <= 0) {
      _showSnackBar('Amount must be greater than 0', isError: true);
      return;
    }

    // Step 2: Create or update expense object
    final newExpense = Expense(
      id: widget.expenseToEdit?.id ?? const Uuid().v4(), // Use existing ID if editing, generate new if adding
      amount: parsedAmount,
      category: _selectedCategory,
      description: description,
      date: _selectedDate,
      isAvoidable: _isAvoidable,
      walletId: _selectedWalletId,
    );

    // Step 3: Pass expense back to dashboard
    widget.onExpenseAdded(newExpense);

    // Step 4: Close this screen
    Navigator.of(context).pop();
  }

  /// Show date picker
  void _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expenseToEdit != null;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final hintColor = isDark ? Colors.white54 : Colors.black54;
    final labelColor = isDark ? Colors.white : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 4,
        toolbarHeight: kToolbarHeight,
        automaticallyImplyLeading: true,
        title: Text(
          isEditing ? 'Edit Expense' : 'Add Expense',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 24,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Label
            Text(
              'Amount',
              style: TextStyle(
                fontSize: AppDimensions.fontMedium,
                fontWeight: FontWeight.w600,
                color: labelColor,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              style: TextStyle(color: textColor),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Enter amount (e.g., 50.00)',
                hintStyle: TextStyle(color: hintColor),
                prefixText: '\ ',
                prefixStyle: TextStyle(color: textColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Description Label
            Text(
              'Description',
              style: TextStyle(
                fontSize: AppDimensions.fontMedium,
                fontWeight: FontWeight.w600,
                color: labelColor,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'What did you spend on?',
                hintStyle: TextStyle(color: hintColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Category Label
            Text(
              'Category',
              style: TextStyle(
                fontSize: AppDimensions.fontMedium,
                fontWeight: FontWeight.w600,
                color: labelColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                underline: SizedBox(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                items: categories.map((String value) {
                  final category = CategoryManager.getCategoryByName(value);
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        Icon(
                          category?.icon,
                          size: 20,
                          color: category?.color,
                        ),
                        const SizedBox(width: 8),
                        Text(value, style: TextStyle(color: textColor)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 24),

            // Date Label
            Text(
              'Date',
              style: TextStyle(
                fontSize: AppDimensions.fontMedium,
                fontWeight: FontWeight.w600,
                color: labelColor,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                decoration: BoxDecoration(
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: TextStyle(
                        fontSize: AppDimensions.fontMedium,
                        color: textColor,
                      ),
                    ),
                    Icon(Icons.calendar_today, color: textColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Wallet Label
            Text(
              'Wallet',
              style: TextStyle(
                fontSize: AppDimensions.fontMedium,
                fontWeight: FontWeight.w600,
                color: labelColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              child: DropdownButton<String>(
                value: _selectedWalletId,
                isExpanded: true,
                underline: const SizedBox(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                items: _wallets.map((wallet) {
                  return DropdownMenuItem<String>(
                    value: wallet.id,
                    child: Row(
                      children: [
                        Icon(wallet.icon, size: 20, color: wallet.color),
                        const SizedBox(width: 8),
                        Text(wallet.name, style: TextStyle(color: textColor)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedWalletId = val;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 24),

            // Avoidable Toggle
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Avoidable Expense',
                        style: TextStyle(
                          fontSize: AppDimensions.fontMedium,
                          fontWeight: FontWeight.w600,
                          color: labelColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Is this expense avoidable?',
                        style: TextStyle(
                          fontSize: AppDimensions.fontSmall,
                          color: hintColor,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: _isAvoidable,
                    onChanged: (value) {
                      setState(() {
                        _isAvoidable = value;
                      });
                    },
                    activeThumbColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSaveExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                ),
                child: Text(
                  isEditing ? 'Update Expense' : 'Add Expense',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppDimensions.fontLarge,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
