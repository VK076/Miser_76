import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/currency.dart';
import '../models/expense.dart';
import '../services/expense_database.dart';
import '../services/budget_database.dart';
import '../services/income_database.dart';
import '../services/export_service.dart';
import '../main.dart';
import '../widgets/expense_card_widget.dart';
import '../widgets/filter_buttons_widget.dart';
import '../widgets/analytics_widget.dart';
import '../utils/dummy_data_seeder.dart';
import 'login_screen.dart';
import 'search_screen.dart';
import 'add_expense_screen.dart';
import 'recurring_transactions_screen.dart';
import 'settings_screen.dart';
import '../services/smart_parser_service.dart';
import '../services/csv_import_service.dart';
import 'package:file_picker/file_picker.dart';

class DashboardScreen extends StatefulWidget {
  final Currency selectedCurrency;
  final Function(Currency) onCurrencyChanged;

  const DashboardScreen({
    Key? key,
    required this.selectedCurrency,
    required this.onCurrencyChanged,
  }) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  final _db = ExpenseDatabase();
  final _smartParser = SmartParserService();
  final _csvImporter = CsvImportService();
  final _quickAddController = TextEditingController();
  List<Expense> expenses = [];

  String searchQuery = '';
  String timeFilter = 'month';
  String sortBy = 'date'; // 'date', 'amount', 'category'
  DateTime? customStartDate;
  DateTime? customEndDate;
  
  late final ScrollController _expensesScrollController;
  late final ScrollController _analyticsScrollController;
  late final TabController _tabController;
  bool _showScrollButton = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _expensesScrollController = ScrollController();
    _analyticsScrollController = ScrollController();
    _expensesScrollController.addListener(_updateScrollButtonVisibility);
    _analyticsScrollController.addListener(_updateScrollButtonVisibility);
    _loadExpenses();
  }

  void _loadExpenses() {
    setState(() {
      expenses = _db.getAllExpenses();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _expensesScrollController.dispose();
    _analyticsScrollController.dispose();
    _quickAddController.dispose();
    super.dispose();
  }

  // Computed properties
  List<Expense> get timeFilteredExpenses {
    final now = DateTime.now();
    List<Expense> filtered;
    if (timeFilter == 'month') {
      filtered = expenses.where((e) => e.date.year == now.year && e.date.month == now.month).toList();
    } else if (timeFilter == 'year') {
      filtered = expenses.where((e) => e.date.year == now.year).toList();
    } else if (timeFilter == 'custom' && customStartDate != null && customEndDate != null) {
      filtered = expenses.where((e) => 
        e.date.isAfter(customStartDate!) && 
        e.date.isBefore(customEndDate!.add(const Duration(days: 1)))
      ).toList();
    } else {
      filtered = expenses.where((e) => e.date.year == now.year && e.date.month == now.month).toList();
    }
    
    // Apply sorting
    if (sortBy == 'date') {
      filtered.sort((a, b) => b.date.compareTo(a.date)); // Newest first
    } else if (sortBy == 'amount') {
      filtered.sort((a, b) => b.amount.compareTo(a.amount)); // Highest first
    } else if (sortBy == 'category') {
      filtered.sort((a, b) => a.category.compareTo(b.category)); // A-Z
    }
    
    return filtered;
  }

  List<Expense> get filteredExpenses {
    if (searchQuery.isEmpty) return timeFilteredExpenses;
    return timeFilteredExpenses.where((expense) {
      return expense.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
             expense.category.toLowerCase().contains(searchQuery.toLowerCase()) ||
             expense.amount.toString().contains(searchQuery);
    }).toList();
  }

  double get totalSpent => timeFilteredExpenses.fold(0.0, (sum, e) => sum + e.amount);

  Map<String, double> get categorySpending {
    final Map<String, double> spending = {};
    for (var expense in timeFilteredExpenses) {
      spending[expense.category] = (spending[expense.category] ?? 0) + expense.amount;
    }
    return spending;
  }

  Widget _buildAnalyticsTab(ThemeData theme) {
    return AnalyticsWidget(
      expenses: filteredExpenses,
      currency: widget.selectedCurrency,
      scrollController: _analyticsScrollController,
    );
  }

  String formatCurrency(double amount) {
    return '${widget.selectedCurrency.symbol}${amount.toStringAsFixed(2)}';
  }

  void _updateScrollButtonVisibility() {
    final controller = _tabController.index == 0 ? _expensesScrollController : _analyticsScrollController;
    final shouldShow = controller.hasClients && controller.offset > 200;
    if (shouldShow != _showScrollButton) {
      setState(() => _showScrollButton = shouldShow);
    }
  }

  void _scrollToTop() {
    final controller = _tabController.index == 0 ? _expensesScrollController : _analyticsScrollController;
    controller.animateTo(0, duration: AppAnimations.normal, curve: Curves.easeOut);
  }

  void _showCustomDatePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: customStartDate != null && customEndDate != null
          ? DateTimeRange(start: customStartDate!, end: customEndDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        customStartDate = picked.start;
        customEndDate = picked.end;
        timeFilter = 'custom';
        searchQuery = '';
      });
    }
  }

  void _deleteExpense(String id) async {
    await _db.deleteExpense(id);
    _loadExpenses();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense deleted'), duration: Duration(seconds: 2)),
      );
    }
  }

  void _handleQuickAdd(String text) {
    if (text.trim().isEmpty) return;

    try {
      final expense = _smartParser.parse(text);
      
      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Amount: ${formatCurrency(expense.amount)}'),
              Text('Category: ${expense.category}'),
              Text('Description: ${expense.description}'),
              if (expense.walletId != null) 
                 Text('Wallet: ${expense.walletId}'), // In real app, show wallet name
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _db.addExpense(expense);
                _quickAddController.clear();
                _loadExpenses();
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not parse: $e')),
      );
    }
  }

  Future<void> _handleCsvImport() async {
    try {
      // Pick CSV file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.single.path == null) {
        return; // User canceled
      }

      final filePath = result.files.single.path!;
      
      // Show loading
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Import CSV
      final importResult = await _csvImporter.importFromFile(filePath);
      
      // Close loading
      if (!mounted) return;
      Navigator.pop(context);

      // Show preview dialog
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Import Preview'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${importResult.successCount} expenses found',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (importResult.hasErrors) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${importResult.errors.length} errors',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                const SizedBox(height: 16),
                if (importResult.expenses.isNotEmpty) ...[
                  const Text('Preview (first 5):'),
                  const SizedBox(height: 8),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: importResult.expenses.take(5).length,
                      itemBuilder: (context, index) {
                        final expense = importResult.expenses[index];
                        return ListTile(
                          dense: true,
                          title: Text('${formatCurrency(expense.amount)} - ${expense.category}'),
                          subtitle: Text(expense.description),
                        );
                      },
                    ),
                  ),
                ],
                if (importResult.hasErrors) ...[
                  const SizedBox(height: 16),
                  const Text('Errors:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: importResult.errors.take(5).length,
                      itemBuilder: (context, index) {
                        return Text(
                          '• ${importResult.errors[index]}',
                          style: const TextStyle(fontSize: 12, color: Colors.red),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            if (importResult.expenses.isNotEmpty)
              ElevatedButton(
                onPressed: () async {
                  // Import all expenses
                  for (final expense in importResult.expenses) {
                    await _db.addExpense(expense);
                  }
                  _loadExpenses();
                  if (!mounted) return;
                  Navigator.pop(context);
                  
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Successfully imported ${importResult.successCount} expenses'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('Import All'),
              ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    }
  }


  void _editExpense(Expense expense) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(
          onExpenseAdded: (updatedExpense) async {
            await _db.updateExpense(updatedExpense);
            _loadExpenses();
          },
          expenseToEdit: expense,
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    final exportService = ExportService();
    final budgetDb = BudgetDatabase();
    final incomeDb = IncomeDatabase();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose what to export:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Expenses'),
              subtitle: const Text('Export all expenses to CSV'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final csv = await exportService.exportExpensesToCSV(
                    expenses,
                    widget.selectedCurrency,
                  );
                  await exportService.shareCSV(csv, 'expenses_${DateTime.now().millisecondsSinceEpoch}.csv');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Expenses exported successfully!')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Export failed: $e')),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Income'),
              subtitle: const Text('Export all income to CSV'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final incomeList = incomeDb.getAllIncome();
                  final csv = await exportService.exportIncomeToCSV(
                    incomeList,
                    widget.selectedCurrency,
                  );
                  await exportService.shareCSV(csv, 'income_${DateTime.now().millisecondsSinceEpoch}.csv');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Income exported successfully!')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Export failed: $e')),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Budgets'),
              subtitle: const Text('Export all budgets to CSV'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final budgets = budgetDb.getAllBudgets();
                  final now = DateTime.now();
                  final spending = <String, double>{};
                  for (var budget in budgets) {
                    final categoryExpenses = expenses.where((e) =>
                        e.category == budget.category &&
                        e.date.year == now.year &&
                        e.date.month == now.month);
                    spending[budget.category] = categoryExpenses.fold(0.0, (sum, e) => sum + e.amount);
                  }
                  final csv = await exportService.exportBudgetsToCSV(
                    budgets,
                    spending,
                    widget.selectedCurrency,
                  );
                  await exportService.shareCSV(csv, 'budgets_${DateTime.now().millisecondsSinceEpoch}.csv');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Budgets exported successfully!')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Export failed: $e')),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Combined Report'),
              subtitle: const Text('Export everything to one file'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final budgets = budgetDb.getAllBudgets();
                  final incomeList = incomeDb.getAllIncome();
                  final now = DateTime.now();
                  final spending = <String, double>{};
                  for (var budget in budgets) {
                    final categoryExpenses = expenses.where((e) =>
                        e.category == budget.category &&
                        e.date.year == now.year &&
                        e.date.month == now.month);
                    spending[budget.category] = categoryExpenses.fold(0.0, (sum, e) => sum + e.amount);
                  }
                  final csv = await exportService.exportCombinedReport(
                    expenses,
                    incomeList,
                    budgets,
                    spending,
                    widget.selectedCurrency,
                  );
                  await exportService.shareCSV(csv, 'financial_report_${DateTime.now().millisecondsSinceEpoch}.csv');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Report exported successfully!')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Export failed: $e')),
                    );
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file, color: Colors.white),
            onPressed: () => _handleCsvImport(),
            tooltip: 'Import CSV',
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () => _showExportDialog(context),
            tooltip: 'Export data',
          ),
          IconButton(
            icon: const Icon(Icons.repeat, color: Colors.white),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => RecurringTransactionsScreen(selectedCurrency: widget.selectedCurrency)),
            ),
            tooltip: 'Recurring transactions',
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SettingsScreen(
                  selectedCurrency: widget.selectedCurrency,
                  onCurrencyChanged: widget.onCurrencyChanged,
                  isDarkMode: isDark,
                  onThemeChanged: (val) => MyApp.setTheme(context, val),
                ),
              ),
            ),
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Expenses', icon: Icon(Icons.list)),
            Tab(text: 'Analytics', icon: Icon(Icons.pie_chart)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExpensesTab(theme),
          _buildAnalyticsTab(theme),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_showScrollButton) ...[
            FloatingActionButton(
              backgroundColor: AppColors.success,
              onPressed: _scrollToTop,
              heroTag: 'scroll_button',
              child: const Icon(Icons.arrow_upward),
            ),
            const SizedBox(height: 16),
          ],
          FloatingActionButton(
            backgroundColor: AppColors.primary,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddExpenseScreen(
                  onExpenseAdded: (newExpense) async {
                    await _db.addExpense(newExpense);
                    _loadExpenses();
                  },
                ),
              ),
            ),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesTab(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return SingleChildScrollView(
      controller: _expensesScrollController,
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Add Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _quickAddController,
              decoration: InputDecoration(
                hintText: 'Quick Add (e.g., "15 coffee")',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primary),
                  onPressed: () => _handleQuickAdd(_quickAddController.text),
                ),
                prefixIcon: const Icon(Icons.bolt, color: Colors.orange),
              ),
              onSubmitted: _handleQuickAdd,
            ),
          ),

          // Total Spent Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.primaryGradient),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.totalSpent,
                  style: TextStyle(color: Colors.white70, fontSize: AppDimensions.fontMedium),
                ),
                const SizedBox(height: 8),
                Text(
                  formatCurrency(totalSpent),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppDimensions.fontHeading,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeFilter == 'month' ? AppStrings.thisMonth : timeFilter == 'year' ? 'This Year' : 'Custom Range',
                  style: const TextStyle(color: Colors.white70, fontSize: AppDimensions.fontSmall),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Filter Buttons
          FilterButtonsWidget(
            selectedFilter: timeFilter,
            onFilterChanged: (filter) => setState(() {
              timeFilter = filter;
              searchQuery = '';
            }),
            customStartDate: customStartDate,
            customEndDate: customEndDate,
            onCustomDatePressed: _showCustomDatePicker,
          ),

          const SizedBox(height: 20),

          // Search Bar
          // Search Bar (Navigates to Advanced Search)
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SearchScreen(selectedCurrency: widget.selectedCurrency),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  const SizedBox(width: 12),
                  Text(
                    'Search expenses...',
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Recent Expenses Title
          Text(
            AppStrings.recentExpenses,
            style: TextStyle(
              fontSize: AppDimensions.fontLarge,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),

          const SizedBox(height: 16),

          // Expenses List or Empty State
          if (filteredExpenses.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingXLarge),
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 48, color: secondaryTextColor),
                    const SizedBox(height: 12),
                    Text(
                      searchQuery.isEmpty ? 'No expenses yet' : 'No results found for "$searchQuery"',
                      style: TextStyle(color: secondaryTextColor, fontSize: AppDimensions.fontMedium),
                    ),
                  ],
                ),
              ),
            )
          else
            ...filteredExpenses.map((expense) => ExpenseCardWidget(
              expense: expense,
              onEdit: () => _editExpense(expense),
              onDelete: () => _deleteExpense(expense.id),
              currency: widget.selectedCurrency,
            )),
        ],
      ),
    );
  }


}