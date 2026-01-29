import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/storage_service.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';
import 'claim_form_screen.dart';

/// Screen for viewing claim details.
/// 
/// Displays:
/// - Patient information
/// - All bills
/// - Financial summary
/// - Status history and transitions
/// - Edit/delete actions (for draft claims)
class ClaimDetailScreen extends StatelessWidget {
  /// The ID of the claim to display
  final String claimId;

  const ClaimDetailScreen({
    super.key,
    required this.claimId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ClaimsProvider>(
      builder: (context, provider, child) {
        final claim = provider.getClaimById(claimId);

        if (claim == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Claim Details')),
            body: const Center(
              child: Text('Claim not found'),
            ),
          );
        }

        return _ClaimDetailContent(claim: claim);
      },
    );
  }
}

class _ClaimDetailContent extends StatelessWidget {
  final Claim claim;

  const _ClaimDetailContent({required this.claim});

  void _navigateToEdit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ClaimFormScreen(claim: claim),
      ),
    );
  }

  Future<void> _deleteClaim(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Claim',
      message: 'Are you sure you want to delete this claim for ${claim.patientName}? This action cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      final success = await context.read<ClaimsProvider>().deleteClaim(claim.id);
      if (success && context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Claim deleted successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _changeStatus(BuildContext context) async {
    final newStatus = await StatusTransitionDialog.show(
      context,
      currentStatus: claim.status,
      validTransitions: claim.validNextStatuses,
    );

    if (newStatus != null && context.mounted) {
      final success = await context.read<ClaimsProvider>().transitionClaimStatus(
        claim.id,
        newStatus,
      );

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status changed to ${newStatus.displayName}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (context.mounted) {
        final errorMessage = context.read<ClaimsProvider>().errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? 'Failed to change status'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _exportClaimReport(BuildContext context) {
    StorageService.exportClaimReport(claim);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Claim report exported successfully'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Claim Details'),
        actions: [
          // Export report button
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Export Report',
            onPressed: () => _exportClaimReport(context),
          ),
          if (claim.isEditable) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Claim',
              onPressed: () => _navigateToEdit(context),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete Claim',
              onPressed: () => _deleteClaim(context),
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 800;
          
          if (isWideScreen) {
            return _buildWideLayout(context);
          } else {
            return _buildNarrowLayout(context);
          }
        },
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildStatusCard(context),
                const SizedBox(height: AppSpacing.md),
                _buildPatientInfoCard(),
                const SizedBox(height: AppSpacing.md),
                _buildBillsCard(),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          // Right column
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildFinancialSummaryCard(),
                const SizedBox(height: AppSpacing.md),
                _buildTimelineCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          _buildStatusCard(context),
          const SizedBox(height: AppSpacing.md),
          _buildPatientInfoCard(),
          const SizedBox(height: AppSpacing.md),
          _buildFinancialSummaryCard(),
          const SizedBox(height: AppSpacing.md),
          _buildBillsCard(),
          const SizedBox(height: AppSpacing.md),
          _buildTimelineCard(),
          const SizedBox(height: 80), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final statusColor = AppColors.getStatusColor(claim.status);
    final statusBgColor = AppColors.getStatusBackgroundColor(claim.status);
    final statusIcon = AppColors.getStatusIcon(claim.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        claim.status.displayName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        claim.status.description,
                        style: AppTextStyles.body2,
                      ),
                    ],
                  ),
                ),
                if (claim.validNextStatuses.isNotEmpty)
                  ElevatedButton(
                    onPressed: () => _changeStatus(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: statusColor,
                    ),
                    child: const Text('Change Status'),
                  ),
              ],
            ),
            if (claim.status.isTerminal) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'This claim has reached its final status',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text('Patient Information', style: AppTextStyles.subtitle1),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Patient details grid
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  radius: 32,
                  child: Text(
                    claim.patientName.isNotEmpty 
                        ? claim.patientName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        claim.patientName,
                        style: AppTextStyles.headline3,
                      ),
                      const SizedBox(height: 4),
                      _buildInfoRow(
                        icon: Icons.policy_outlined,
                        label: 'Policy',
                        value: claim.policyNumber,
                      ),
                      _buildInfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Claim Date',
                        value: Formatters.formatDate(claim.claimDate),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textTertiary),
          const SizedBox(width: 4),
          Text(
            '$label: ',
            style: AppTextStyles.caption,
          ),
          Text(
            value,
            style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummaryCard() {
    return Card(
      color: AppColors.primary.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text('Financial Summary', style: AppTextStyles.subtitle1),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Total Bill Amount - Large display
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Bill Amount',
                    style: AppTextStyles.body2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.formatCurrency(claim.totalBillAmount),
                    style: AppTextStyles.currencyLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Breakdown
            _buildFinancialRow(
              label: 'Advance Paid',
              amount: claim.advancePaid,
              color: AppColors.info,
              isDeduction: true,
            ),
            _buildFinancialRow(
              label: 'Settlement Amount',
              amount: claim.settlementAmount,
              color: AppColors.success,
              isDeduction: true,
            ),
            const Divider(height: 24),
            _buildFinancialRow(
              label: 'Pending Amount',
              amount: claim.pendingAmount,
              color: claim.pendingAmount > 0 ? AppColors.warning : AppColors.success,
              isLarge: true,
            ),
            
            if (claim.isFullySettled) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppColors.success,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Fully Settled',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialRow({
    required String label,
    required double amount,
    required Color color,
    bool isDeduction = false,
    bool isLarge = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isLarge ? AppTextStyles.subtitle1 : AppTextStyles.body2,
          ),
          Text(
            '${isDeduction ? '- ' : ''}${Formatters.formatCurrency(amount)}',
            style: TextStyle(
              fontSize: isLarge ? 18 : 14,
              fontWeight: isLarge ? FontWeight.bold : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: AppColors.info,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Bills (${claim.billCount})',
                  style: AppTextStyles.subtitle1,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            
            if (claim.bills.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Center(
                  child: Text(
                    'No bills added',
                    style: AppTextStyles.body2,
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: claim.bills.length,
                itemBuilder: (context, index) {
                  final bill = claim.bills[index];
                  return BillTile(
                    bill: bill,
                    isEditable: false,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.history,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text('Timeline', style: AppTextStyles.subtitle1),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            
            _buildTimelineItem(
              title: 'Created',
              subtitle: Formatters.formatDateTime(claim.createdAt),
              icon: Icons.add_circle_outline,
              color: AppColors.primary,
              isFirst: true,
            ),
            _buildTimelineItem(
              title: 'Last Updated',
              subtitle: Formatters.formatDateTime(claim.updatedAt),
              icon: Icons.update,
              color: AppColors.info,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 8,
                    color: AppColors.textTertiary.withValues(alpha: 0.3),
                  ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.textTertiary.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.subtitle2),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    if (!claim.isEditable && claim.status.isTerminal) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (claim.isEditable) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _navigateToEdit(context),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Claim'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            if (claim.validNextStatuses.isNotEmpty)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _changeStatus(context),
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Change Status'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
