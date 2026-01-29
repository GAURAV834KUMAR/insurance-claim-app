/// Utility class for validating user input.
class Validators {
  Validators._(); // Private constructor to prevent instantiation

  /// Validates that a string is not empty
  static String? validateRequired(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates patient name
  /// - Must not be empty
  /// - Must be at least 2 characters
  /// - Must contain only letters and spaces
  static String? validatePatientName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Patient name is required';
    }
    if (value.trim().length < 2) {
      return 'Patient name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Patient name can only contain letters and spaces';
    }
    return null;
  }

  /// Validates policy number
  /// - Must not be empty
  /// - Must be at least 5 characters
  /// - Must be alphanumeric
  static String? validatePolicyNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Policy number is required';
    }
    if (value.trim().length < 5) {
      return 'Policy number must be at least 5 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value.trim())) {
      return 'Policy number must be alphanumeric';
    }
    return null;
  }

  /// Validates a monetary amount
  /// - Must be a valid number
  /// - Must be non-negative
  /// - Must be greater than 0 if required
  static String? validateAmount(String? value, {
    bool required = true,
    bool allowZero = true,
    String fieldName = 'Amount',
  }) {
    if (value == null || value.trim().isEmpty) {
      if (required) {
        return '$fieldName is required';
      }
      return null;
    }

    final amount = double.tryParse(value.trim());
    if (amount == null) {
      return 'Please enter a valid number';
    }
    if (amount < 0) {
      return '$fieldName cannot be negative';
    }
    if (!allowZero && amount == 0) {
      return '$fieldName must be greater than 0';
    }
    return null;
  }

  /// Validates bill description
  /// - Must not be empty
  /// - Must be at least 3 characters
  static String? validateBillDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }
    if (value.trim().length < 3) {
      return 'Description must be at least 3 characters';
    }
    return null;
  }

  /// Validates that advance paid doesn't exceed total bill amount
  static String? validateAdvancePaid(String? value, double totalBillAmount) {
    final baseValidation = validateAmount(
      value,
      required: false,
      allowZero: true,
      fieldName: 'Advance paid',
    );
    if (baseValidation != null) return baseValidation;

    if (value != null && value.isNotEmpty) {
      final advance = double.tryParse(value.trim()) ?? 0;
      if (advance > totalBillAmount) {
        return 'Advance cannot exceed total bill amount';
      }
    }
    return null;
  }

  /// Validates that settlement amount is valid
  static String? validateSettlementAmount(
    String? value,
    double totalBillAmount,
    double advancePaid,
  ) {
    final baseValidation = validateAmount(
      value,
      required: false,
      allowZero: true,
      fieldName: 'Settlement amount',
    );
    if (baseValidation != null) return baseValidation;

    if (value != null && value.isNotEmpty) {
      final settlement = double.tryParse(value.trim()) ?? 0;
      final maxSettlement = totalBillAmount - advancePaid;
      if (settlement > maxSettlement) {
        return 'Settlement cannot exceed pending amount';
      }
    }
    return null;
  }
}
