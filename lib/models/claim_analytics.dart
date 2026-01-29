import '../models/claim.dart';
import '../models/claim_status.dart';

/// Analytics model for computing claim statistics.
/// Provides insights and metrics for the dashboard.
class ClaimAnalytics {
  final List<Claim> claims;

  ClaimAnalytics(this.claims);

  /// Total number of claims
  int get totalClaims => claims.length;

  /// Claims by status
  Map<ClaimStatus, int> get claimsByStatus {
    final map = <ClaimStatus, int>{};
    for (final status in ClaimStatus.values) {
      map[status] = claims.where((c) => c.status == status).length;
    }
    return map;
  }

  /// Total amount across all claims
  double get totalClaimAmount => 
      claims.fold(0.0, (sum, c) => sum + c.totalBillAmount);

  /// Total pending amount
  double get totalPendingAmount =>
      claims.fold(0.0, (sum, c) => sum + c.pendingAmount);

  /// Total settled amount
  double get totalSettledAmount =>
      claims.fold(0.0, (sum, c) => sum + c.settlementAmount);

  /// Average claim value
  double get averageClaimValue => 
      totalClaims > 0 ? totalClaimAmount / totalClaims : 0;

  /// Approval rate (approved + settled / total non-draft claims)
  double get approvalRate {
    final nonDraft = claims.where((c) => c.status != ClaimStatus.draft).length;
    if (nonDraft == 0) return 0;
    
    final approved = claims.where((c) => 
      c.status == ClaimStatus.approved ||
      c.status == ClaimStatus.partiallysettled ||
      c.status == ClaimStatus.settled
    ).length;
    
    return (approved / nonDraft) * 100;
  }

  /// Rejection rate
  double get rejectionRate {
    final nonDraft = claims.where((c) => c.status != ClaimStatus.draft).length;
    if (nonDraft == 0) return 0;
    
    final rejected = claims.where((c) => c.status == ClaimStatus.rejected).length;
    return (rejected / nonDraft) * 100;
  }

  /// Settlement rate (fully settled / approved claims)
  double get settlementRate {
    final approved = claims.where((c) => 
      c.status == ClaimStatus.approved ||
      c.status == ClaimStatus.partiallysettled ||
      c.status == ClaimStatus.settled
    ).length;
    
    if (approved == 0) return 0;
    
    final settled = claims.where((c) => c.status == ClaimStatus.settled).length;
    return (settled / approved) * 100;
  }

  /// Claims created in last 7 days
  int get recentClaimsCount {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return claims.where((c) => c.createdAt.isAfter(weekAgo)).length;
  }

  /// Highest claim value
  double get highestClaimValue {
    if (claims.isEmpty) return 0;
    return claims.map((c) => c.totalBillAmount).reduce((a, b) => a > b ? a : b);
  }

  /// Lowest claim value (non-zero)
  double get lowestClaimValue {
    final nonZero = claims.where((c) => c.totalBillAmount > 0).toList();
    if (nonZero.isEmpty) return 0;
    return nonZero.map((c) => c.totalBillAmount).reduce((a, b) => a < b ? a : b);
  }

  /// Monthly claim trends (last 6 months)
  Map<String, int> get monthlyTrends {
    final trends = <String, int>{};
    final now = DateTime.now();
    
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthKey = '${_monthName(month.month)} ${month.year}';
      trends[monthKey] = claims.where((c) =>
        c.createdAt.year == month.year && c.createdAt.month == month.month
      ).length;
    }
    
    return trends;
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  /// Status distribution for charts
  List<StatusDistribution> get statusDistribution {
    return ClaimStatus.values.map((status) {
      final count = claimsByStatus[status] ?? 0;
      final percentage = totalClaims > 0 ? (count / totalClaims) * 100 : 0.0;
      return StatusDistribution(
        status: status,
        count: count,
        percentage: percentage,
      );
    }).where((d) => d.count > 0).toList();
  }
}

/// Model for status distribution data
class StatusDistribution {
  final ClaimStatus status;
  final int count;
  final double percentage;

  StatusDistribution({
    required this.status,
    required this.count,
    required this.percentage,
  });
}
