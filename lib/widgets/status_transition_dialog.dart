import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/constants.dart';

/// A dialog for changing claim status.
/// 
/// Only shows valid transitions from the current status.
class StatusTransitionDialog extends StatelessWidget {
  /// The current status of the claim
  final ClaimStatus currentStatus;
  
  /// The list of valid next statuses
  final List<ClaimStatus> validTransitions;

  const StatusTransitionDialog({
    super.key,
    required this.currentStatus,
    required this.validTransitions,
  });

  /// Shows the dialog and returns the selected new status
  static Future<ClaimStatus?> show(
    BuildContext context, {
    required ClaimStatus currentStatus,
    required List<ClaimStatus> validTransitions,
  }) {
    if (validTransitions.isEmpty) {
      // Show a message that no transitions are available
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No status transitions available from ${currentStatus.displayName}',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return Future.value(null);
    }

    return showDialog<ClaimStatus>(
      context: context,
      builder: (context) => StatusTransitionDialog(
        currentStatus: currentStatus,
        validTransitions: validTransitions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Status'),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current status indicator
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  const Text(
                    'Current: ',
                    style: AppTextStyles.body2,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.getStatusBackgroundColor(currentStatus),
                      borderRadius: BorderRadius.circular(AppRadius.circular),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          AppColors.getStatusIcon(currentStatus),
                          size: 14,
                          color: AppColors.getStatusColor(currentStatus),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          currentStatus.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.getStatusColor(currentStatus),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Select new status:',
              style: AppTextStyles.subtitle2,
            ),
            const SizedBox(height: AppSpacing.sm),
            // Status options
            ...validTransitions.map((status) => _buildStatusOption(context, status)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildStatusOption(BuildContext context, ClaimStatus status) {
    final color = AppColors.getStatusColor(status);
    final backgroundColor = AppColors.getStatusBackgroundColor(status);
    final icon = AppColors.getStatusIcon(status);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () => Navigator.of(context).pop(status),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    Text(
                      status.description,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
