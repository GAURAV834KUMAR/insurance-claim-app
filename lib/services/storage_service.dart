import 'dart:convert';
import 'dart:html' as html;
import '../models/models.dart';

/// Service for persisting claims data to browser's localStorage.
/// This ensures data survives page refreshes and browser restarts.
class StorageService {
  static const String _claimsKey = 'insurance_claims_data';
  static const String _themeKey = 'app_theme_mode';

  /// Saves all claims to localStorage
  static void saveClaims(List<Claim> claims) {
    try {
      final jsonData = claims.map((c) => c.toJson()).toList();
      final encoded = jsonEncode(jsonData);
      html.window.localStorage[_claimsKey] = encoded;
    } catch (e) {
      // Silently fail - localStorage might be disabled
      print('Failed to save claims: $e');
    }
  }

  /// Loads all claims from localStorage
  static List<Claim> loadClaims() {
    try {
      final stored = html.window.localStorage[_claimsKey];
      if (stored == null || stored.isEmpty) {
        return [];
      }
      final decoded = jsonDecode(stored) as List<dynamic>;
      return decoded
          .map((json) => Claim.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Failed to load claims: $e');
      return [];
    }
  }

  /// Clears all stored claims
  static void clearClaims() {
    html.window.localStorage.remove(_claimsKey);
  }

  /// Saves theme preference
  static void saveThemeMode(bool isDark) {
    html.window.localStorage[_themeKey] = isDark.toString();
  }

  /// Loads theme preference
  static bool loadThemeMode() {
    final stored = html.window.localStorage[_themeKey];
    return stored == 'true';
  }

  /// Exports claims to CSV and triggers download
  static void exportToCSV(List<Claim> claims) {
    final buffer = StringBuffer();
    
    // CSV Header
    buffer.writeln('Claim ID,Patient Name,Policy Number,Claim Date,Status,Total Bills,Advance Paid,Settlement Amount,Pending Amount,Number of Bills,Created At,Updated At');
    
    // CSV Data rows
    for (final claim in claims) {
      buffer.writeln([
        claim.id,
        '"${claim.patientName}"',
        claim.policyNumber,
        claim.claimDate.toIso8601String().split('T')[0],
        claim.status.displayName,
        claim.totalBillAmount.toStringAsFixed(2),
        claim.advancePaid.toStringAsFixed(2),
        claim.settlementAmount.toStringAsFixed(2),
        claim.pendingAmount.toStringAsFixed(2),
        claim.billCount,
        claim.createdAt.toIso8601String(),
        claim.updatedAt.toIso8601String(),
      ].join(','));
    }

    // Create and download file
    final bytes = utf8.encode(buffer.toString());
    final blob = html.Blob([bytes], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement()
      ..href = url
      ..download = 'insurance_claims_${DateTime.now().millisecondsSinceEpoch}.csv'
      ..style.display = 'none';
    
    html.document.body?.children.add(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
  }

  /// Exports a single claim's detailed report
  static void exportClaimReport(Claim claim) {
    final buffer = StringBuffer();
    
    buffer.writeln('INSURANCE CLAIM REPORT');
    buffer.writeln('=' * 50);
    buffer.writeln('');
    buffer.writeln('PATIENT INFORMATION');
    buffer.writeln('-' * 30);
    buffer.writeln('Patient Name: ${claim.patientName}');
    buffer.writeln('Policy Number: ${claim.policyNumber}');
    buffer.writeln('Claim Date: ${claim.claimDate.toIso8601String().split('T')[0]}');
    buffer.writeln('Current Status: ${claim.status.displayName}');
    buffer.writeln('');
    buffer.writeln('BILLS');
    buffer.writeln('-' * 30);
    
    if (claim.bills.isEmpty) {
      buffer.writeln('No bills added');
    } else {
      for (int i = 0; i < claim.bills.length; i++) {
        final bill = claim.bills[i];
        buffer.writeln('${i + 1}. ${bill.description}: ₹${bill.amount.toStringAsFixed(2)}');
      }
    }
    
    buffer.writeln('');
    buffer.writeln('FINANCIAL SUMMARY');
    buffer.writeln('-' * 30);
    buffer.writeln('Total Bill Amount: ₹${claim.totalBillAmount.toStringAsFixed(2)}');
    buffer.writeln('Advance Paid: ₹${claim.advancePaid.toStringAsFixed(2)}');
    buffer.writeln('Settlement Amount: ₹${claim.settlementAmount.toStringAsFixed(2)}');
    buffer.writeln('Pending Amount: ₹${claim.pendingAmount.toStringAsFixed(2)}');
    buffer.writeln('');
    buffer.writeln('TIMESTAMPS');
    buffer.writeln('-' * 30);
    buffer.writeln('Created: ${claim.createdAt}');
    buffer.writeln('Last Updated: ${claim.updatedAt}');
    buffer.writeln('');
    buffer.writeln('=' * 50);
    buffer.writeln('Generated on: ${DateTime.now()}');

    final bytes = utf8.encode(buffer.toString());
    final blob = html.Blob([bytes], 'text/plain');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement()
      ..href = url
      ..download = 'claim_${claim.policyNumber}_report.txt'
      ..style.display = 'none';
    
    html.document.body?.children.add(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
  }
}
