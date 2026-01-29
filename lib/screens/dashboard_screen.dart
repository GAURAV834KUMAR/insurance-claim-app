import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../providers/theme_provider.dart';
import '../services/storage_service.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';
import 'analytics_screen.dart';
import 'claim_form_screen.dart';
import 'claim_detail_screen.dart';

/// Dashboard screen showing all claims with summary statistics.
/// 
/// This is the main entry point of the application, displaying:
/// - Summary statistics cards
/// - Filter tabs by claim status
/// - List of all claims
/// - FAB to create new claims
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  ClaimSortField _sortField = ClaimSortField.createdAt;
  bool _sortAscending = false;

  // Tab items for filtering
  final List<_FilterTab> _tabs = [
    const _FilterTab(label: 'All', status: null),
    const _FilterTab(label: 'Draft', status: ClaimStatus.draft),
    const _FilterTab(label: 'Submitted', status: ClaimStatus.submitted),
    const _FilterTab(label: 'Approved', status: ClaimStatus.approved),
    const _FilterTab(label: 'Rejected', status: ClaimStatus.rejected),
    const _FilterTab(label: 'Partial', status: ClaimStatus.partiallysettled),
    const _FilterTab(label: 'Settled', status: ClaimStatus.settled),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToCreateClaim() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ClaimFormScreen(),
      ),
    );
  }

  void _navigateToClaimDetail(Claim claim) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ClaimDetailScreen(claimId: claim.id),
      ),
    );
  }

  void _navigateToEditClaim(Claim claim) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ClaimFormScreen(claim: claim),
      ),
    );
  }

  void _navigateToAnalytics() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AnalyticsScreen(),
      ),
    );
  }

  void _exportClaims(List<Claim> claims) {
    if (claims.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No claims to export')),
      );
      return;
    }
    StorageService.exportToCSV(claims);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exported ${claims.length} claims to CSV'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _deleteClaim(Claim claim) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Claim',
      message: 'Are you sure you want to delete this claim for ${claim.patientName}? This action cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      final success = await context.read<ClaimsProvider>().deleteClaim(claim.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Claim deleted successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  List<Claim> _getFilteredClaims(ClaimsProvider provider) {
    List<Claim> claims;
    
    // Apply status filter based on selected tab
    final selectedTab = _tabs[_tabController.index];
    if (selectedTab.status != null) {
      claims = List<Claim>.from(provider.getClaimsByStatus(selectedTab.status!));
    } else {
      claims = List<Claim>.from(provider.claims);
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      claims = claims.where((c) =>
        c.patientName.toLowerCase().contains(query) ||
        c.policyNumber.toLowerCase().contains(query)
      ).toList();
    }

    // Apply sorting
    claims.sort((a, b) {
      int comparison;
      switch (_sortField) {
        case ClaimSortField.patientName:
          comparison = a.patientName.compareTo(b.patientName);
          break;
        case ClaimSortField.claimDate:
          comparison = a.claimDate.compareTo(b.claimDate);
          break;
        case ClaimSortField.totalAmount:
          comparison = a.totalBillAmount.compareTo(b.totalBillAmount);
          break;
        case ClaimSortField.pendingAmount:
          comparison = a.pendingAmount.compareTo(b.pendingAmount);
          break;
        case ClaimSortField.status:
          comparison = a.status.index.compareTo(b.status.index);
          break;
        case ClaimSortField.createdAt:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case ClaimSortField.updatedAt:
          comparison = a.updatedAt.compareTo(b.updatedAt);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return claims;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111118) : const Color(0xFFF4F7FB),
      body: Consumer<ClaimsProvider>(
        builder: (context, provider, child) {
          return CustomScrollView(
            slivers: [
              // Modern App Bar
              SliverAppBar(
                floating: false,
                pinned: true,
                expandedHeight: 90,
                toolbarHeight: 70,
                backgroundColor: isDark ? const Color(0xFF111118) : const Color(0xFFF4F7FB),
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                title: Row(
                  children: [
                    // Logo/Brand section - using Material icon for browser compatibility
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.medical_services_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Insurance Claims',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF1A1D29),
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            '${provider.claimCount} total claims',
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
                actions: [
                  // Modern action buttons in a container
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? Colors.white.withOpacity(0.08) 
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark 
                            ? Colors.white.withOpacity(0.1) 
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Dark mode toggle
                        Consumer<ThemeProvider>(
                          builder: (context, themeProvider, _) {
                            return _buildIconButton(
                              icon: themeProvider.isDarkMode 
                                  ? Icons.light_mode_rounded 
                                  : Icons.dark_mode_rounded,
                              tooltip: themeProvider.isDarkMode 
                                  ? 'Light Mode' 
                                  : 'Dark Mode',
                              onPressed: () => themeProvider.toggleTheme(),
                              isDark: isDark,
                            );
                          },
                        ),
                        _buildIconButton(
                          icon: Icons.analytics_rounded,
                          tooltip: 'Analytics',
                          onPressed: _navigateToAnalytics,
                          isDark: isDark,
                        ),
                        _buildIconButton(
                          icon: Icons.download_rounded,
                          tooltip: 'Export CSV',
                          onPressed: () => _exportClaims(_getFilteredClaims(provider)),
                          isDark: isDark,
                        ),
                        _buildIconButton(
                          icon: Icons.sort_rounded,
                          tooltip: 'Sort',
                          onPressed: () => _showSortOptions(context),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  // Cloud status indicator
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: provider.isUsingFirestore
                            ? [Colors.green.withOpacity(0.15), Colors.green.withOpacity(0.08)]
                            : [Colors.orange.withOpacity(0.15), Colors.orange.withOpacity(0.08)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: provider.isUsingFirestore
                            ? Colors.green.withOpacity(0.3)
                            : Colors.orange.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          provider.isUsingFirestore
                              ? Icons.cloud_done_rounded
                              : Icons.cloud_off_rounded,
                          color: provider.isUsingFirestore ? Colors.green : Colors.orange,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          provider.isUsingFirestore ? 'Synced' : 'Local',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: provider.isUsingFirestore ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Statistics Cards
              SliverToBoxAdapter(
                child: _buildStatisticsSection(provider),
              ),

              // Modern Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark 
                          ? const Color(0xFF252533) 
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark 
                            ? Colors.white.withOpacity(0.08) 
                            : const Color(0xFFE2E8F0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1A1D29),
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search by patient name or policy number...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                          fontSize: 15,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: isDark ? Colors.white54 : const Color(0xFF64748B),
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: 16,
                        ),
                      ),
                      onChanged: (value) => setState(() => _searchQuery = value),
                    ),
                  ),
                ),
              ),

              // Filter Tabs
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    onTap: (_) => setState(() {}),
                    tabs: _tabs.map((tab) {
                      final count = tab.status == null
                          ? provider.claimCount
                          : provider.getClaimsByStatus(tab.status!).length;
                      return Tab(
                        child: Row(
                          children: [
                            Text(tab.label),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                count.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Claims List
              _buildClaimsList(provider),
            ],
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _navigateToCreateClaim,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'New Claim',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(ClaimsProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive grid based on available width
          final crossAxisCount = constraints.maxWidth > 700
              ? 4
              : constraints.maxWidth > 400
                  ? 2
                  : 2;
          
          // Adjust aspect ratio based on screen size - wider cards for smaller screens
          final aspectRatio = constraints.maxWidth > 600 
              ? 1.8 
              : constraints.maxWidth > 400 
                  ? 1.5 
                  : 1.3;

          return GridView.count(
            crossAxisCount: crossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: aspectRatio,
            children: [
              StatCard(
                title: 'Total Claims',
                value: provider.claimCount.toString(),
                icon: Icons.description_outlined,
                color: AppColors.primary,
              ),
              StatCard(
                title: 'Total Value',
                value: Formatters.formatCurrency(provider.totalClaimsValue),
                icon: Icons.account_balance_wallet_outlined,
                color: AppColors.info,
              ),
              StatCard(
                title: 'Pending',
                value: Formatters.formatCurrency(provider.totalPendingAmount),
                icon: Icons.pending_outlined,
                color: AppColors.warning,
              ),
              StatCard(
                title: 'Settled',
                value: Formatters.formatCurrency(provider.totalSettledAmount),
                icon: Icons.check_circle_outline,
                color: AppColors.success,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildClaimsList(ClaimsProvider provider) {
    final filteredClaims = _getFilteredClaims(provider);

    if (provider.isEmpty) {
      return SliverFillRemaining(
        child: EmptyClaimsState(
          onCreateClaim: _navigateToCreateClaim,
        ),
      );
    }

    if (filteredClaims.isEmpty && _searchQuery.isNotEmpty) {
      return SliverFillRemaining(
        child: EmptySearchState(query: _searchQuery),
      );
    }

    if (filteredClaims.isEmpty) {
      return SliverFillRemaining(
        child: EmptyState(
          icon: Icons.filter_list_off,
          title: 'No Claims Found',
          description: 'No claims match the selected filter.',
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.md),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final claim = filteredClaims[index];
            return ClaimCard(
              claim: claim,
              onTap: () => _navigateToClaimDetail(claim),
              onEdit: claim.isEditable
                  ? () => _navigateToEditClaim(claim)
                  : null,
              onDelete: claim.isEditable
                  ? () => _deleteClaim(claim)
                  : null,
            );
          },
          childCount: filteredClaims.length,
        ),
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Sort By', style: AppTextStyles.headline3),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ..._sortOptions.map((option) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(option.label),
                leading: Icon(
                  _sortField == option.field
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: _sortField == option.field
                      ? AppColors.primary
                      : AppColors.textTertiary,
                ),
                trailing: _sortField == option.field
                    ? Icon(
                        _sortAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 20,
                        color: AppColors.primary,
                      )
                    : null,
                onTap: () {
                  setState(() {
                    if (_sortField == option.field) {
                      _sortAscending = !_sortAscending;
                    } else {
                      _sortField = option.field;
                      _sortAscending = true;
                    }
                  });
                  Navigator.pop(context);
                },
              )),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? Colors.white70 : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  final List<_SortOption> _sortOptions = const [
    _SortOption(label: 'Created Date', field: ClaimSortField.createdAt),
    _SortOption(label: 'Updated Date', field: ClaimSortField.updatedAt),
    _SortOption(label: 'Patient Name', field: ClaimSortField.patientName),
    _SortOption(label: 'Claim Date', field: ClaimSortField.claimDate),
    _SortOption(label: 'Total Amount', field: ClaimSortField.totalAmount),
    _SortOption(label: 'Pending Amount', field: ClaimSortField.pendingAmount),
    _SortOption(label: 'Status', field: ClaimSortField.status),
  ];
}

/// Filter tab data class
class _FilterTab {
  final String label;
  final ClaimStatus? status;

  const _FilterTab({
    required this.label,
    this.status,
  });
}

/// Sort option data class
class _SortOption {
  final String label;
  final ClaimSortField field;

  const _SortOption({
    required this.label,
    required this.field,
  });
}

/// Custom delegate for persistent tab bar header
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111118) : const Color(0xFFF4F7FB),
        boxShadow: overlapsContent ? [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark 
              ? Colors.white.withOpacity(0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark 
                ? Colors.white.withOpacity(0.08) 
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: tabBar,
      ),
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height + 20;

  @override
  double get minExtent => tabBar.preferredSize.height + 20;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
