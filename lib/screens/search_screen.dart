import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../services/expense_database.dart';
import '../constants/app_constants.dart';
import '../constants/currency.dart';
import '../widgets/expense_card_widget.dart';

class SearchScreen extends StatefulWidget {
  final Currency selectedCurrency;

  const SearchScreen({
    Key? key,
    required this.selectedCurrency,
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _expenseDb = ExpenseDatabase();
  final _searchController = TextEditingController();
  
  List<Expense> _allExpenses = [];
  List<Expense> _filteredExpenses = [];
  
  // Filters
  String _query = '';
  String? _selectedCategory;
  DateTimeResults? _dateRange;
  RangeValues _amountRange = const RangeValues(0, 10000);
  double _maxAmount = 10000;

  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final expenses = _expenseDb.getAllExpenses();
    double max = 0;
    for (var e in expenses) {
      if (e.amount > max) max = e.amount;
    }
    
    // Round up to nearest 100
    max = (max / 100).ceil() * 100.0;
    if (max == 0) max = 1000;

    setState(() {
      _allExpenses = expenses;
      _filteredExpenses = expenses;
      _maxAmount = max;
      _amountRange = RangeValues(0, max);
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredExpenses = _allExpenses.where((e) {
        // Text Search
        final matchesQuery = _query.isEmpty ||
            e.description.toLowerCase().contains(_query.toLowerCase()) ||
            e.category.toLowerCase().contains(_query.toLowerCase()) ||
            e.amount.toString().contains(_query);

        if (!matchesQuery) return false;

        // Category Filter
        if (_selectedCategory != null && e.category != _selectedCategory) {
          return false;
        }

        // Date Range Filter
        if (_dateRange != null) {
          if (e.date.isBefore(_dateRange!.start) || e.date.isAfter(_dateRange!.end.add(const Duration(days: 1)))) {
            return false;
          }
        }

        // Amount Range Filter
        if (e.amount < _amountRange.start || e.amount > _amountRange.end) {
          return false;
        }

        return true;
      }).toList();
      
      // Sort by date desc
      _filteredExpenses.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _query = '';
      _selectedCategory = null;
      _dateRange = null;
      _amountRange = RangeValues(0, _maxAmount);
      _filteredExpenses = List.from(_allExpenses);
       _filteredExpenses.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search & Filter'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetFilters,
            tooltip: 'Reset Filters',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar Area
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? AppColors.darkSurface : Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() => _query = val);
                    _applyFilters();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search expenses...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                              _applyFilters();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => setState(() => _showFilters = !_showFilters),
                  child: Row(
                    children: [
                      Icon(
                        _showFilters ? Icons.keyboard_arrow_up : Icons.filter_list,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _showFilters ? 'Hide Advanced Filters' : 'Show Advanced Filters',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Filters Section (Expandable)
          if (_showFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: isDark ? AppColors.darkSurface : Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Categories'),
                      ),
                      ...CategoryManager.allCategories.map((c) => DropdownMenuItem(
                        value: c.name,
                        child: Row(
                          children: [
                            Icon(c.icon, size: 16, color: c.color),
                            const SizedBox(width: 8),
                            Text(c.name),
                          ],
                        ),
                      )),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedCategory = val);
                      _applyFilters();
                    },
                  ),
                  const SizedBox(height: 16),

                  // Amount Range Slider
                  Text('Amount Range: ${widget.selectedCurrency.symbol}${_amountRange.start.toInt()} - ${widget.selectedCurrency.symbol}${_amountRange.end.toInt()}'),
                  RangeSlider(
                    values: _amountRange,
                    min: 0,
                    max: _maxAmount,
                    divisions: 100,
                    activeColor: AppColors.primary,
                    labels: RangeLabels(
                      '${_amountRange.start.toInt()}',
                      '${_amountRange.end.toInt()}',
                    ),
                    onChanged: (values) {
                      setState(() => _amountRange = values);
                      _applyFilters();
                    },
                  ),
                  
                  // Date Picker Button
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDateRange: _dateRange != null
                            ? DateTimeRange(start: _dateRange!.start, end: _dateRange!.end)
                            : null,
                      );
                      if (picked != null) {
                        setState(() {
                          _dateRange = DateTimeResults(picked.start, picked.end);
                        });
                        _applyFilters();
                      } else if (_dateRange != null) {
                        // Allow clearing date range
                         setState(() => _dateRange = null);
                         _applyFilters();
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_dateRange == null 
                      ? 'Select Date Range' 
                      : '${_dateRange!.start.toString().split(' ')[0]} - ${_dateRange!.end.toString().split(' ')[0]}'),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

          // Results List
          Expanded(
            child: _filteredExpenses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 80, color: AppColors.primary.withOpacity(0.2)),
                        const SizedBox(height: 16),
                        Text(
                          _query.isEmpty ? 'Search significantly better' : 'No matches found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        if (_query.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Try adjusting your filters',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredExpenses.length,
                    itemBuilder: (context, index) {
                      return ExpenseCardWidget(
                        expense: _filteredExpenses[index],
                        onEdit: () {}, // We can add edit functionality later or navigate
                        onDelete: () {}, // Read-only for search or allow delete? Let's keep read-only for safety or implement full logic
                        currency: widget.selectedCurrency,
                        showActions: false, // Hide edit/delete for search view to keep it simple for now
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class DateTimeResults {
  final DateTime start;
  final DateTime end;
  DateTimeResults(this.start, this.end);
}
