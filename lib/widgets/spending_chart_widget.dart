import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/app_constants.dart';
import '../models/category.dart';
import '../constants/currency.dart';

class SpendingChartWidget extends StatelessWidget {
  final Map<String, double> categorySpending;
  final double totalSpent;
  final Currency currency;

  const SpendingChartWidget({
    Key? key,
    required this.categorySpending,
    required this.totalSpent,
    required this.currency,
  }) : super(key: key);

  String formatCurrency(double amount) {
    return '${currency.symbol}${amount.toStringAsFixed(2)}';
  }

  List<Color> _getColorsList(List<String> categories) {
    return categories.map((category) {
      final categoryObj = CategoryManager.getCategoryByName(category);
      return categoryObj?.color ?? AppColors.primary;
    }).toList();
  }

  List<PieChartSectionData> _buildPieSections(
    List<String> categories,
    List<double> spending,
    List<Color> colors,
  ) {
    return List.generate(categories.length, (index) {
      final percentage = (spending[index] / totalSpent * 100);
      return PieChartSectionData(
        color: colors[index],
        value: spending[index],
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    if (categorySpending.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingXLarge),
          child: Column(
            children: [
              Icon(
                Icons.pie_chart_outline,
                size: 64,
                color: secondaryTextColor,
              ),
              const SizedBox(height: 16),
              Text(
                'No expenses to analyze yet',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: AppDimensions.fontMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final categories = categorySpending.keys.toList();
    final spending = categorySpending.values.toList();
    final colors = _getColorsList(categories);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pie Chart
        SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              sections: _buildPieSections(categories, spending, colors),
              centerSpaceRadius: 0,
              sectionsSpace: 2,
            ),
          ),
        ),

        const SizedBox(height: AppDimensions.paddingLarge),

        // Category Breakdown Title
        Text(
          'Category Breakdown',
          style: TextStyle(
            fontSize: AppDimensions.fontLarge,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),

        const SizedBox(height: AppDimensions.paddingMedium),

        // Category List
        ...List.generate(categories.length, (index) {
          final category = categories[index];
          final amount = spending[index];
          final percentage = (amount / totalSpent * 100);
          final categoryObj = CategoryManager.getCategoryByName(category);

          return Container(
            margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                // Category Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (categoryObj?.color ?? AppColors.primary).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  child: Icon(
                    categoryObj?.icon ?? Icons.category,
                    color: categoryObj?.color ?? AppColors.primary,
                    size: 20,
                  ),
                ),
                
                const SizedBox(width: AppDimensions.paddingMedium),
                
                // Category Name and Percentage
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: AppDimensions.fontMedium,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${percentage.toStringAsFixed(1)}% of total',
                        style: TextStyle(
                          fontSize: AppDimensions.fontSmall,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Amount
                Text(
                  formatCurrency(amount),
                  style: TextStyle(
                    fontSize: AppDimensions.fontLarge,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
