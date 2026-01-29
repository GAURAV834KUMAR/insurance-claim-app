import 'package:intl/intl.dart';

/// Utility class for formatting various data types consistently across the app.
class Formatters {
  Formatters._(); // Private constructor to prevent instantiation

  /// Currency formatter for displaying monetary values
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 2,
    locale: 'en_IN',
  );

  /// Compact currency formatter for large amounts
  static final NumberFormat _compactCurrencyFormatter = NumberFormat.compactCurrency(
    symbol: '₹',
    decimalDigits: 1,
    locale: 'en_IN',
  );

  /// Date formatter for displaying dates
  static final DateFormat _dateFormatter = DateFormat('dd MMM yyyy');

  /// Date formatter with time
  static final DateFormat _dateTimeFormatter = DateFormat('dd MMM yyyy, hh:mm a');

  /// Short date formatter
  static final DateFormat _shortDateFormatter = DateFormat('dd/MM/yyyy');

  /// Formats a double value as currency
  /// Example: 1500.50 → ₹1,500.50
  static String formatCurrency(double amount) {
    return _currencyFormatter.format(amount);
  }

  /// Alias for formatCurrency for cleaner API
  static String currency(double amount) => formatCurrency(amount);

  /// Formats a double value as compact currency
  /// Example: 150000 → ₹1.5L
  static String compactCurrency(double amount) {
    return _compactCurrencyFormatter.format(amount);
  }

  /// Formats a DateTime to a readable date string
  /// Example: 2026-01-28 → 28 Jan 2026
  static String formatDate(DateTime date) {
    return _dateFormatter.format(date);
  }

  /// Formats a DateTime to a readable date and time string
  /// Example: 2026-01-28 14:30 → 28 Jan 2026, 02:30 PM
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormatter.format(dateTime);
  }

  /// Formats a DateTime to a short date string
  /// Example: 2026-01-28 → 28/01/2026
  static String formatShortDate(DateTime date) {
    return _shortDateFormatter.format(date);
  }

  /// Formats a number with commas for thousands separator
  /// Example: 1500000 → 15,00,000
  static String formatNumber(num number) {
    return NumberFormat('#,##,###', 'en_IN').format(number);
  }

  /// Formats a policy number for display (adds dashes for readability)
  /// Example: POL123456789 → POL-1234-5678-9
  static String formatPolicyNumber(String policyNumber) {
    // If already formatted or too short, return as-is
    if (policyNumber.contains('-') || policyNumber.length < 4) {
      return policyNumber;
    }
    return policyNumber.toUpperCase();
  }
}
