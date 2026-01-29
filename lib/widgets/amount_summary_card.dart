import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// A card widget for displaying summary amounts (Total, Advance, Pending, etc.)
class AmountSummaryCard extends StatelessWidget {
  /// The items to display in the summary
  final List<AmountSummaryItem> items;
  
  /// Optional title for the card
  final String? title;

  const AmountSummaryCard({
    super.key,
    required this.items,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(title!, style: AppTextStyles.subtitle1),
              const SizedBox(height: AppSpacing.md),
            ],
            ...items.map((item) => _buildSummaryRow(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(AmountSummaryItem item) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: item.isHighlighted ? AppSpacing.sm : AppSpacing.xs,
        top: item.isHighlighted ? AppSpacing.sm : 0,
      ),
      child: Column(
        children: [
          if (item.isHighlighted)
            const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.label,
                style: item.isHighlighted
                    ? AppTextStyles.subtitle1
                    : AppTextStyles.body2,
              ),
              Text(
                item.value,
                style: TextStyle(
                  fontSize: item.isHighlighted ? 18 : 14,
                  fontWeight: item.isHighlighted 
                      ? FontWeight.bold 
                      : FontWeight.w500,
                  color: item.color ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Represents a single item in the amount summary
class AmountSummaryItem {
  /// The label for this amount
  final String label;
  
  /// The formatted value
  final String value;
  
  /// Optional color for the value
  final Color? color;
  
  /// Whether this item should be highlighted (e.g., total)
  final bool isHighlighted;

  const AmountSummaryItem({
    required this.label,
    required this.value,
    this.color,
    this.isHighlighted = false,
  });
}
