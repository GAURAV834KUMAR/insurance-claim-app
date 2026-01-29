import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../utils/utils.dart';

/// A dialog for adding or editing a bill.
/// 
/// Returns the created/updated Bill if saved, or null if cancelled.
class BillDialog extends StatefulWidget {
  /// Existing bill to edit (null for creating new bill)
  final Bill? bill;

  const BillDialog({
    super.key,
    this.bill,
  });

  /// Shows the dialog and returns the result
  static Future<Bill?> show(BuildContext context, {Bill? bill}) {
    return showDialog<Bill>(
      context: context,
      builder: (context) => BillDialog(bill: bill),
    );
  }

  @override
  State<BillDialog> createState() => _BillDialogState();
}

class _BillDialogState extends State<BillDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;

  bool get isEditing => widget.bill != null;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.bill?.description ?? '',
    );
    _amountController = TextEditingController(
      text: widget.bill?.amount.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final bill = Bill(
        id: widget.bill?.id, // Keep same ID if editing
        description: _descriptionController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        createdAt: widget.bill?.createdAt, // Keep original creation date if editing
      );
      Navigator.of(context).pop(bill);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Edit Bill' : 'Add Bill'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'e.g., Consultation Fee, X-Ray, etc.',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: Validators.validateBillDescription,
                autofocus: true,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: 'Enter amount',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: (value) => Validators.validateAmount(
                  value,
                  allowZero: false,
                  fieldName: 'Amount',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          child: Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
