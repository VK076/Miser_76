import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class FilterButtonsWidget extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final VoidCallback onCustomDatePressed;

  const FilterButtonsWidget({
    Key? key,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.customStartDate,
    this.customEndDate,
    required this.onCustomDatePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Column(
      children: [
        // Monthly and Yearly Filters
        Row(
          children: [
            Expanded(
              child: _buildFilterButton(
                context,
                label: 'Monthly',
                value: 'month',
                isSelected: selectedFilter == 'month',
                surfaceColor: surfaceColor,
                textColor: textColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFilterButton(
                context,
                label: 'Yearly',
                value: 'year',
                isSelected: selectedFilter == 'year',
                surfaceColor: surfaceColor,
                textColor: textColor,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Custom Date Range Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onCustomDatePressed,
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text(
              selectedFilter == 'custom' && customStartDate != null && customEndDate != null
                  ? '${customStartDate!.day}/${customStartDate!.month}/${customStartDate!.year} - ${customEndDate!.day}/${customEndDate!.month}/${customEndDate!.year}'
                  : 'Custom Date Range',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppDimensions.fontMedium,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: selectedFilter == 'custom' ? AppColors.primary : textColor,
              side: BorderSide(
                color: selectedFilter == 'custom' ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.border),
                width: selectedFilter == 'custom' ? 2 : 1,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
                vertical: AppDimensions.paddingSmall + 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton(
    BuildContext context, {
    required String label,
    required String value,
    required bool isSelected,
    required Color surfaceColor,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: () => onFilterChanged(value),
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall + 2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : surfaceColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: isSelected ? AppColors.primary : (Theme.of(context).brightness == Brightness.dark ? AppColors.darkBorder : AppColors.border),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : textColor,
              fontSize: AppDimensions.fontMedium,
            ),
          ),
        ),
      ),
    );
  }
}
