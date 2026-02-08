import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../constants/currency.dart';

class ExpenseCardWidget extends StatelessWidget {
  final Expense expense;
  final VoidCallback onEdit;
  final Function() onDelete;
  final Currency currency;
  final bool showActions;

  const ExpenseCardWidget({
    Key? key,
    required this.expense,
    required this.onEdit,
    required this.onDelete,
    required this.currency,
    this.showActions = true,
  }) : super(key: key);

  String formatCurrency(double amount) {
    return '${currency.symbol}${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    
    final categoryObj = CategoryManager.getCategoryByName(expense.category);
    final categoryColor = categoryObj?.color ?? AppColors.primary;

    return Hero(
      tag: 'expense_${expense.id}',
      child: Card(
        margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        elevation: 2,
        color: surfaceColor,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Row(
              children: [
                // Category Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  child: Icon(
                    categoryObj?.icon ?? Icons.category,
                    color: categoryColor,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: AppDimensions.paddingMedium),
                
                // Expense Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.description,
                        style: TextStyle(
                          fontSize: AppDimensions.fontLarge,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(
                            Icons.label_outline,
                            size: 14,
                            color: secondaryTextColor,
                          ),
                          Text(
                            expense.category,
                            style: TextStyle(
                              fontSize: AppDimensions.fontSmall,
                              color: secondaryTextColor,
                            ),
                          ),
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: secondaryTextColor,
                          ),
                          Text(
                            '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                            style: TextStyle(
                              fontSize: AppDimensions.fontSmall,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: AppDimensions.paddingSmall),
                
                // Amount and Actions
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatCurrency(expense.amount),
                      style: TextStyle(
                        fontSize: AppDimensions.fontLarge,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: onEdit,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: secondaryTextColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: onDelete,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
