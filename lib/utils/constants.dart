import 'package:flutter/material.dart';
import '../models/claim_status.dart';

/// App-wide color constants and theme utilities
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary brand colors
  static const Color primary = Color(0xFF2563EB); // Blue 600
  static const Color primaryLight = Color(0xFF3B82F6); // Blue 500
  static const Color primaryDark = Color(0xFF1D4ED8); // Blue 700

  // Secondary colors
  static const Color secondary = Color(0xFF7C3AED); // Violet 600
  static const Color secondaryLight = Color(0xFF8B5CF6); // Violet 500

  // Background colors
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Slate 100

  // Text colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textTertiary = Color(0xFF94A3B8); // Slate 400

  // Status colors
  static const Color success = Color(0xFF22C55E); // Green 500
  static const Color successLight = Color(0xFFDCFCE7); // Green 100
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningLight = Color(0xFFFEF3C7); // Amber 100
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorLight = Color(0xFFFEE2E2); // Red 100
  static const Color info = Color(0xFF3B82F6); // Blue 500
  static const Color infoLight = Color(0xFFDBEAFE); // Blue 100

  // Claim status colors
  static const Color draft = Color(0xFF6B7280); // Gray 500
  static const Color draftLight = Color(0xFFF3F4F6); // Gray 100
  static const Color submitted = Color(0xFF3B82F6); // Blue 500
  static const Color submittedLight = Color(0xFFDBEAFE); // Blue 100
  static const Color approved = Color(0xFF22C55E); // Green 500
  static const Color approvedLight = Color(0xFFDCFCE7); // Green 100
  static const Color rejected = Color(0xFFEF4444); // Red 500
  static const Color rejectedLight = Color(0xFFFEE2E2); // Red 100
  static const Color partiallySettled = Color(0xFFF59E0B); // Amber 500
  static const Color partiallySettledLight = Color(0xFFFEF3C7); // Amber 100
  static const Color settled = Color(0xFF10B981); // Emerald 500
  static const Color settledLight = Color(0xFFD1FAE5); // Emerald 100

  /// Map of status to color for quick lookup
  static const Map<ClaimStatus, Color> statusColors = {
    ClaimStatus.draft: draft,
    ClaimStatus.submitted: submitted,
    ClaimStatus.approved: approved,
    ClaimStatus.rejected: rejected,
    ClaimStatus.partiallysettled: partiallySettled,
    ClaimStatus.settled: settled,
  };

  /// Returns the appropriate color for a claim status
  static Color getStatusColor(ClaimStatus status) {
    switch (status) {
      case ClaimStatus.draft:
        return draft;
      case ClaimStatus.submitted:
        return submitted;
      case ClaimStatus.approved:
        return approved;
      case ClaimStatus.rejected:
        return rejected;
      case ClaimStatus.partiallysettled:
        return partiallySettled;
      case ClaimStatus.settled:
        return settled;
    }
  }

  /// Returns the appropriate background color for a claim status chip
  static Color getStatusBackgroundColor(ClaimStatus status) {
    switch (status) {
      case ClaimStatus.draft:
        return draftLight;
      case ClaimStatus.submitted:
        return submittedLight;
      case ClaimStatus.approved:
        return approvedLight;
      case ClaimStatus.rejected:
        return rejectedLight;
      case ClaimStatus.partiallysettled:
        return partiallySettledLight;
      case ClaimStatus.settled:
        return settledLight;
    }
  }

  /// Returns the appropriate icon for a claim status
  static IconData getStatusIcon(ClaimStatus status) {
    switch (status) {
      case ClaimStatus.draft:
        return Icons.edit_note_rounded;
      case ClaimStatus.submitted:
        return Icons.send_rounded;
      case ClaimStatus.approved:
        return Icons.check_circle_rounded;
      case ClaimStatus.rejected:
        return Icons.cancel_rounded;
      case ClaimStatus.partiallysettled:
        return Icons.hourglass_bottom_rounded;
      case ClaimStatus.settled:
        return Icons.verified_rounded;
    }
  }
}

/// App-wide text styles
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitle1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitle2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textTertiary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle currencyLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle currencyMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
}

/// App-wide spacing constants
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// App-wide border radius constants
class AppRadius {
  AppRadius._();

  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double xxl = 24.0;
  static const double circular = 100.0;
}
