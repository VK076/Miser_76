import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../constants/app_constants.dart';
import '../constants/currency.dart';

class AnalyticsWidget extends StatelessWidget {
  final List<Expense> expenses;
  final Currency currency;
  final ScrollController? scrollController;

  const AnalyticsWidget({
    Key? key,
    required this.expenses,
    required this.currency,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryTotals = _calculateCategoryTotals();
    final totalExpenses = categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('No expenses to analyze', style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Donut Chart with Total in Center
          _buildDonutChart(categoryTotals, totalExpenses, isDark),
          const SizedBox(height: 32),
          
          // Category Breakdown Header
          Text(
            'Category Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // Category List
          ...categoryTotals.entries.map((entry) {
            final category = CategoryManager.getCategoryByName(entry.key);
            final percentage = (entry.value / totalExpenses * 100);
            return _buildCategoryItem(
              category: category,
              amount: entry.value,
              percentage: percentage,
              isDark: isDark,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDonutChart(Map<String, double> categoryTotals, double total, bool isDark) {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 80,
              sections: _buildPieChartSections(categoryTotals, total),
              pieTouchData: PieTouchData(enabled: false),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${currency.symbol}${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, double> categoryTotals, double total) {
    return categoryTotals.entries.map((entry) {
      final category = CategoryManager.getCategoryByName(entry.key);
      final percentage = (entry.value / total * 100);
      
      return PieChartSectionData(
        color: category?.color ?? Colors.grey,
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildCategoryItem({
    required Category? category,
    required double amount,
    required double percentage,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Category Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: category?.color.withOpacity(0.15) ?? Colors.grey.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              category?.icon ?? Icons.category,
              color: category?.color ?? Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          
          // Category Name
          Expanded(
            child: Text(
              category?.name ?? 'Unknown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          
          // Percentage
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: category?.color.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: category?.color ?? Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Amount
          Text(
            '${currency.symbol}${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _calculateCategoryTotals() {
    final Map<String, double> totals = {};
    for (var expense in expenses) {
      totals[expense.category] = (totals[expense.category] ?? 0) + expense.amount;
    }
    
    // Sort by amount descending
    final sortedEntries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sortedEntries);
  }
}
