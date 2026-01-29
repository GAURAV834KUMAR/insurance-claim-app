import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/utils.dart';

/// A tile widget for displaying a single bill item.
/// 
/// Supports editing and deleting (when editable is true).
class BillTile extends StatelessWidget {
  /// The bill to display
  final Bill bill;
  
  /// Whether the bill can be edited/deleted
  final bool isEditable;
  
  /// Callback when edit is pressed
  final VoidCallback? onEdit;
  
  /// Callback when delete is pressed
  final VoidCallback? onDelete;

  const BillTile({
    super.key,
    required this.bill,
    this.isEditable = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: const Icon(
            Icons.receipt_outlined,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          bill.description,
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          'Added ${Formatters.formatDate(bill.createdAt)}',
          style: AppTextStyles.caption,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Formatters.formatCurrency(bill.amount),
              style: AppTextStyles.subtitle1.copyWith(
                color: AppColors.primary,
              ),
            ),
            if (isEditable) ...[
              const SizedBox(width: AppSpacing.sm),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit?.call();
                  } else if (value == 'delete') {
                    onDelete?.call();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
