import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/app_constants.dart';
import '../constants/currency.dart';
import '../models/category.dart';

class BudgetIncomeExpenseChart extends StatelessWidget {
  final Map<String, double> categorySpending;
  final Map<String, double> categoryBudgets;
  final double totalIncome;
  final double totalExpenses;
  final Currency currency;

  const BudgetIncomeExpenseChart({
    Key? key,
    required this.categorySpending,
    required this.categoryBudgets,
    required this.totalIncome,
    required this.totalExpenses,
    required this.currency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final netBalance = totalIncome - totalExpenses;
    final savingsRate = totalIncome > 0 ? ((netBalance / totalIncome) * 100) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overview Cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Income',
                totalIncome,
                AppColors.success,
                Icons.arrow_downward,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Expenses',
                totalExpenses,
                AppColors.error,
                Icons.arrow_upward,
                isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Net Balance',
                netBalance,
                netBalance >= 0 ? AppColors.success : AppColors.error,
                netBalance >= 0 ? Icons.trending_up : Icons.trending_down,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Savings Rate',
                savingsRate.toDouble(),
                AppColors.primary,
                Icons.savings,
                isDark,
                isPercentage: true,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Bar Chart: Budget vs Actual
        Text(
          'Budget vs Actual Spending',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),

        if (categoryBudgets.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.account_balance_wallet_outlined,
                      size: 48, color: secondaryTextColor),
                  const SizedBox(height: 12),
                  Text(
                    'No budgets set yet',
                    style: TextStyle(color: secondaryTextColor),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxY(),
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final categories = categoryBudgets.keys.toList();
                        if (value.toInt() >= 0 && value.toInt() < categories.length) {
                          final category = categories[value.toInt()];
                          final categoryObj = CategoryManager.getCategoryByName(category);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Icon(
                              categoryObj?.icon ?? Icons.category,
                              size: 20,
                              color: categoryObj?.color ?? AppColors.primary,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${currency.symbol}${value.toInt()}',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _getMaxY() / 5,
                ),
                borderData: FlBorderData(show: false),
                barGroups: _buildBarGroups(),
              ),
            ),
          ),

        const SizedBox(height: 16),

        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Budget', AppColors.primary.withOpacity(0.3)),
            const SizedBox(width: 24),
            _buildLegendItem('Actual', AppColors.primary),
          ],
        ),

        const SizedBox(height: 24),

        // Category Details
        Text(
          'Category Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),

        ...categoryBudgets.entries.map((entry) {
          final category = entry.key;
          final budget = entry.value;
          final spent = categorySpending[category] ?? 0;
          final remaining = budget - spent;
          final progress = (spent / budget).clamp(0.0, 1.0);
          final isOverBudget = spent > budget;
          final categoryObj = CategoryManager.getCategoryByName(category);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isOverBudget
                    ? AppColors.error.withOpacity(0.3)
                    : (isDark ? AppColors.darkBorder : AppColors.border),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(categoryObj?.icon, color: categoryObj?.color, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                    Text(
                      '${currency.symbol}${spent.toStringAsFixed(0)} / ${currency.symbol}${budget.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isOverBudget ? AppColors.error : textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
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
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isOverBudget
                          ? 'Over by ${currency.symbol}${(-remaining).toStringAsFixed(2)}'
                          : 'Remaining: ${currency.symbol}${remaining.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isOverBudget ? AppColors.error : AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    double value,
    Color color,
    IconData icon,
    bool isDark, {
    bool isPercentage = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const Spacer(),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isPercentage
                ? '${value.toStringAsFixed(1)}%'
                : '${currency.symbol}${value.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  double _getMaxY() {
    double max = 0;
    for (var entry in categoryBudgets.entries) {
      final budget = entry.value;
      final spent = categorySpending[entry.key] ?? 0;
      if (budget > max) max = budget;
      if (spent > max) max = spent;
    }
    return (max * 1.2).ceilToDouble();
  }

  List<BarChartGroupData> _buildBarGroups() {
    final categories = categoryBudgets.keys.toList();
    return List.generate(categories.length, (index) {
      final category = categories[index];
      final budget = categoryBudgets[category] ?? 0;
      final spent = categorySpending[category] ?? 0;
      final categoryObj = CategoryManager.getCategoryByName(category);
      final color = categoryObj?.color ?? AppColors.primary;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: budget,
            color: color.withOpacity(0.3),
            width: 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          BarChartRodData(
            toY: spent,
            color: color,
            width: 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }
}
