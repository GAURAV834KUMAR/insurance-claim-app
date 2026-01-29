import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

/// Screen for creating or editing a claim.
/// 
/// Supports:
/// - Creating new claims
/// - Editing existing claims (only in draft status)
/// - Adding/editing/deleting bills
/// - Automatic calculations
class ClaimFormScreen extends StatefulWidget {
  /// Existing claim to edit (null for creating new claim)
  final Claim? claim;

  const ClaimFormScreen({
    super.key,
    this.claim,
  });

  @override
  State<ClaimFormScreen> createState() => _ClaimFormScreenState();
}

class _ClaimFormScreenState extends State<ClaimFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  late TextEditingController _patientNameController;
  late TextEditingController _policyNumberController;
  late TextEditingController _advancePaidController;
  late TextEditingController _settlementAmountController;
  
  // Form state
  late DateTime _claimDate;
  late List<Bill> _bills;
  
  bool get isEditing => widget.claim != null;

  @override
  void initState() {
    super.initState();
    
    // Initialize with existing claim data or defaults
    final claim = widget.claim;
    _patientNameController = TextEditingController(
      text: claim?.patientName ?? '',
    );
    _policyNumberController = TextEditingController(
      text: claim?.policyNumber ?? '',
    );
    _advancePaidController = TextEditingController(
      text: claim?.advancePaid.toString() ?? '0',
    );
    _settlementAmountController = TextEditingController(
      text: claim?.settlementAmount.toString() ?? '0',
    );
    _claimDate = claim?.claimDate ?? DateTime.now();
    _bills = claim != null ? List<Bill>.from(claim.bills) : [];
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _policyNumberController.dispose();
    _advancePaidController.dispose();
    _settlementAmountController.dispose();
    super.dispose();
  }

  // Calculate total bill amount from all bills
  double get _totalBillAmount {
    if (_bills.isEmpty) return 0.0;
    return _bills.fold(0.0, (sum, bill) => sum + bill.amount);
  }

  // Calculate pending amount
  double get _pendingAmount {
    final advance = double.tryParse(_advancePaidController.text) ?? 0.0;
    final settlement = double.tryParse(_settlementAmountController.text) ?? 0.0;
    final pending = _totalBillAmount - advance - settlement;
    return pending < 0 ? 0.0 : pending;
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _claimDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _claimDate) {
      setState(() => _claimDate = picked);
    }
  }

  Future<void> _addBill() async {
    final bill = await BillDialog.show(context);
    if (bill != null) {
      setState(() => _bills.add(bill));
    }
  }

  Future<void> _editBill(Bill bill) async {
    final updatedBill = await BillDialog.show(context, bill: bill);
    if (updatedBill != null) {
      setState(() {
        final index = _bills.indexWhere((b) => b.id == bill.id);
        if (index != -1) {
          _bills[index] = updatedBill;
        }
      });
    }
  }

  Future<void> _deleteBill(Bill bill) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Bill',
      message: 'Are you sure you want to delete "${bill.description}"?',
      confirmText: 'Delete',
      isDestructive: true,
    );
    if (confirmed) {
      setState(() {
        _bills.removeWhere((b) => b.id == bill.id);
      });
    }
  }

  Future<void> _saveClaim() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_bills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one bill'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final provider = context.read<ClaimsProvider>();
    
    final advance = double.tryParse(_advancePaidController.text) ?? 0.0;
    final settlement = double.tryParse(_settlementAmountController.text) ?? 0.0;

    if (isEditing) {
      // Update existing claim
      final updatedClaim = widget.claim!.copyWith(
        patientName: _patientNameController.text.trim(),
        policyNumber: _policyNumberController.text.trim().toUpperCase(),
        claimDate: _claimDate,
        bills: _bills,
        advancePaid: advance,
        settlementAmount: settlement,
      );
      
      final success = await provider.updateClaim(updatedClaim);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Claim updated successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to update claim'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    } else {
      // Create new claim
      await provider.createClaim(
        patientName: _patientNameController.text.trim(),
        policyNumber: _policyNumberController.text.trim().toUpperCase(),
        claimDate: _claimDate,
        bills: _bills,
        advancePaid: advance,
        settlementAmount: settlement,
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Claim created successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Claim' : 'Create New Claim'),
        actions: [
          TextButton.icon(
            onPressed: _saveClaim,
            icon: const Icon(Icons.check),
            label: const Text('Save'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive layout
            final isWideScreen = constraints.maxWidth > 800;
            
            if (isWideScreen) {
              return _buildWideLayout();
            } else {
              return _buildNarrowLayout();
            }
          },
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column - Patient details
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildPatientDetailsCard(),
                const SizedBox(height: AppSpacing.md),
                _buildBillsCard(),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          // Right column - Summary
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildPaymentDetailsCard(),
                const SizedBox(height: AppSpacing.md),
                _buildSummaryCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          _buildPatientDetailsCard(),
          const SizedBox(height: AppSpacing.md),
          _buildBillsCard(),
          const SizedBox(height: AppSpacing.md),
          _buildPaymentDetailsCard(),
          const SizedBox(height: AppSpacing.md),
          _buildSummaryCard(),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildPatientDetailsCard() {
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
                const Text('Patient Details', style: AppTextStyles.subtitle1),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Patient Name
            TextFormField(
              controller: _patientNameController,
              decoration: const InputDecoration(
                labelText: 'Patient Name *',
                hintText: 'Enter patient\'s full name',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              textCapitalization: TextCapitalization.words,
              validator: Validators.validatePatientName,
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Policy Number
            TextFormField(
              controller: _policyNumberController,
              decoration: const InputDecoration(
                labelText: 'Policy Number *',
                hintText: 'e.g., POL123456',
                prefixIcon: Icon(Icons.policy_outlined),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: Validators.validatePolicyNumber,
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Claim Date
            InkWell(
              onTap: () => _selectDate(context),
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Claim Date *',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                child: Text(
                  Formatters.formatDate(_claimDate),
                  style: AppTextStyles.body1,
                ),
              ),
            ),
          ],
        ),
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
                const Text('Bills', style: AppTextStyles.subtitle1),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: _addBill,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Bill'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            
            if (_bills.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        'No bills added yet',
                        style: AppTextStyles.body2,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        'Click "Add Bill" to add bills',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _bills.length,
                itemBuilder: (context, index) {
                  final bill = _bills[index];
                  return BillTile(
                    bill: bill,
                    isEditable: true,
                    onEdit: () => _editBill(bill),
                    onDelete: () => _deleteBill(bill),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsCard() {
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
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.payments_outlined,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text('Payment Details', style: AppTextStyles.subtitle1),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Advance Paid
            TextFormField(
              controller: _advancePaidController,
              decoration: const InputDecoration(
                labelText: 'Advance Paid',
                hintText: '0',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: (value) => Validators.validateAdvancePaid(
                value,
                _totalBillAmount,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Settlement Amount
            TextFormField(
              controller: _settlementAmountController,
              decoration: const InputDecoration(
                labelText: 'Settlement Amount',
                hintText: '0',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: (value) => Validators.validateSettlementAmount(
                value,
                _totalBillAmount,
                double.tryParse(_advancePaidController.text) ?? 0.0,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final advance = double.tryParse(_advancePaidController.text) ?? 0.0;
    final settlement = double.tryParse(_settlementAmountController.text) ?? 0.0;
    
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
                    Icons.calculate_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text('Summary', style: AppTextStyles.subtitle1),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            
            AmountSummaryCard(
              items: [
                AmountSummaryItem(
                  label: 'Total Bill Amount',
                  value: Formatters.formatCurrency(_totalBillAmount),
                  color: AppColors.textPrimary,
                ),
                AmountSummaryItem(
                  label: 'Advance Paid',
                  value: '- ${Formatters.formatCurrency(advance)}',
                  color: AppColors.info,
                ),
                AmountSummaryItem(
                  label: 'Settlement Amount',
                  value: '- ${Formatters.formatCurrency(settlement)}',
                  color: AppColors.success,
                ),
                AmountSummaryItem(
                  label: 'Pending Amount',
                  value: Formatters.formatCurrency(_pendingAmount),
                  color: _pendingAmount > 0 ? AppColors.warning : AppColors.success,
                  isHighlighted: true,
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Number of bills indicator
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${_bills.length} bill${_bills.length != 1 ? 's' : ''} added',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
