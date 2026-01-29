import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/claim_analytics.dart';
import '../providers/providers.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/status_pie_chart.dart';
import '../widgets/monthly_bar_chart.dart';
import '../widgets/animated_progress_bar.dart';
import 'package:provider/provider.dart';

/// Analytics screen showing detailed claim statistics and insights.
/// Features custom charts built without external dependencies.
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111118) : const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 12),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: isDark ? Colors.white : const Color(0xFF1A1D29),
                size: 20,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'Analytics & Insights',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: isDark ? Colors.white : const Color(0xFF1A1D29),
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<ClaimsProvider>(
        builder: (context, provider, _) {
          final analytics = ClaimAnalytics(provider.claims);
          
          if (analytics.totalClaims == 0) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No data to analyze',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create some claims to see analytics',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 20 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Stats Row
                _buildQuickStats(context, analytics),
                const SizedBox(height: 20),

                // Status Distribution Chart
                _buildCard(
                  context,
                  title: 'Status Distribution',
                  icon: Icons.pie_chart_outline,
                  child: Center(
                    child: StatusPieChart(
                      data: analytics.statusDistribution,
                      size: MediaQuery.of(context).size.width > 400 ? 200 : 150,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Monthly Trends
                _buildCard(
                  context,
                  title: 'Monthly Claim Trends',
                  subtitle: 'Last 6 months',
                  icon: Icons.trending_up,
                  child: MonthlyBarChart(
                    data: analytics.monthlyTrends,
                    height: 160,
                  ),
                ),
                const SizedBox(height: 16),

                // Performance Metrics
                _buildCard(
                  context,
                  title: 'Performance Metrics',
                  icon: Icons.speed,
                  child: Column(
                    children: [
                      AnimatedProgressBar(
                        value: analytics.approvalRate / 100,
                        label: 'Approval Rate',
                        color: AppColors.approved,
                      ),
                      const SizedBox(height: 12),
                      AnimatedProgressBar(
                        value: analytics.settlementRate / 100,
                        label: 'Settlement Rate',
                        color: AppColors.settled,
                      ),
                      const SizedBox(height: 12),
                      AnimatedProgressBar(
                        value: analytics.rejectionRate / 100,
                        label: 'Rejection Rate',
                        color: AppColors.rejected,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Financial Summary
                _buildCard(
                  context,
                  title: 'Financial Summary',
                  icon: Icons.account_balance_wallet_outlined,
                  child: Column(
                    children: [
                      _buildFinancialRow(
                        'Total Claim Amount',
                        Formatters.currency(analytics.totalClaimAmount),
                        Icons.receipt_long_outlined,
                        AppColors.primary,
                      ),
                      const Divider(height: 24),
                      _buildFinancialRow(
                        'Total Settled',
                        Formatters.currency(analytics.totalSettledAmount),
                        Icons.check_circle_outline,
                        AppColors.settled,
                      ),
                      const Divider(height: 24),
                      _buildFinancialRow(
                        'Total Pending',
                        Formatters.currency(analytics.totalPendingAmount),
                        Icons.pending_outlined,
                        AppColors.warning,
                      ),
                      const Divider(height: 24),
                      _buildFinancialRow(
                        'Average Claim Value',
                        Formatters.currency(analytics.averageClaimValue),
                        Icons.calculate_outlined,
                        Colors.purple,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Claim Range
                _buildCard(
                  context,
                  title: 'Claim Value Range',
                  icon: Icons.swap_vert,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildRangeItem(
                          'Highest',
                          Formatters.currency(analytics.highestClaimValue),
                          Icons.arrow_upward,
                          Colors.green,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 60,
                        color: Colors.grey.shade300,
                      ),
                      Expanded(
                        child: _buildRangeItem(
                          'Lowest',
                          Formatters.currency(analytics.lowestClaimValue),
                          Icons.arrow_downward,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, ClaimAnalytics analytics) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GridView.count(
      crossAxisCount: screenWidth > 600 ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: screenWidth > 400 ? 1.6 : 1.4,
      children: [
        _buildStatCard(
          'Total Claims',
          analytics.totalClaims.toString(),
          Icons.folder_outlined,
          AppColors.primary,
        ),
        _buildStatCard(
          'This Week',
          analytics.recentClaimsCount.toString(),
          Icons.calendar_today_outlined,
          Colors.teal,
        ),
        _buildStatCard(
          'Approval Rate',
          '${analytics.approvalRate.toStringAsFixed(1)}%',
          Icons.thumb_up_outlined,
          AppColors.approved,
        ),
        _buildStatCard(
          'Avg Value',
          Formatters.compactCurrency(analytics.averageClaimValue),
          Icons.trending_up,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF252538), const Color(0xFF1E1E2D)]
                      : [Colors.white, const Color(0xFFF8FAFC)],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark
                      ? color.withOpacity(0.2)
                      : color.withOpacity(0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(height: 10),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1A1D29),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : const Color(0xFF64748B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
    String? subtitle,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(screenWidth > 400 ? 22 : 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF252538), const Color(0xFF1C1C2D)]
                  : [Colors.white, const Color(0xFFFAFBFC)],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark 
                  ? Colors.white.withOpacity(0.08) 
                  : const Color(0xFFE8EDF3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.15),
                          AppColors.secondary.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF1A1D29),
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white54 : const Color(0xFF64748B),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.15), color.withOpacity(0.08)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: color,
                fontSize: 16,
                letterSpacing: -0.3,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRangeItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.15), color.withOpacity(0.08)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white54 : const Color(0xFF64748B),
              ),
            ),
          ],
        );
      },
    );
  }
}
