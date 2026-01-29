import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// A widget to display when there's no data to show.
/// 
/// Provides a consistent empty state experience across the app.
class EmptyState extends StatelessWidget {
  /// Icon to display
  final IconData icon;
  
  /// Main title text
  final String title;
  
  /// Optional description text
  final String? description;
  
  /// Optional action button
  final Widget? action;
  
  /// Size of the icon
  final double iconSize;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.action,
    this.iconSize = 80,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modern icon container with gradient border
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6366F1).withOpacity(0.3),
                    const Color(0xFF8B5CF6).withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: isDark 
                      ? const Color(0xFF252533) 
                      : const Color(0xFFF8FAFC),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: isDark 
                      ? Colors.white38 
                      : const Color(0xFF94A3B8),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1D29),
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                description!,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white54 : const Color(0xFF64748B),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Pre-configured empty state for claims
class EmptyClaimsState extends StatelessWidget {
  /// Callback when the "Create Claim" button is pressed
  final VoidCallback? onCreateClaim;

  const EmptyClaimsState({
    super.key,
    this.onCreateClaim,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.description_outlined,
      title: 'No Claims Yet',
      description: 'Create your first insurance claim to get started.',
      action: onCreateClaim != null
          ? _ModernButton(
              onPressed: onCreateClaim!,
              label: 'Create New Claim',
              icon: Icons.add_rounded,
            )
          : null,
    );
  }
}

/// Modern gradient button widget
class _ModernButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;

  const _ModernButton({
    required this.onPressed,
    required this.label,
    required this.icon,
  });

  @override
  State<_ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<_ModernButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(_isHovered ? 0.5 : 0.3),
              blurRadius: _isHovered ? 20 : 12,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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
}

/// Pre-configured empty state for bills
class EmptyBillsState extends StatelessWidget {
  /// Callback when the "Add Bill" button is pressed
  final VoidCallback? onAddBill;

  const EmptyBillsState({
    super.key,
    this.onAddBill,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'No Bills Added',
      description: 'Add bills to calculate the total claim amount.',
      iconSize: 48,
      action: onAddBill != null
          ? OutlinedButton.icon(
              onPressed: onAddBill,
              icon: const Icon(Icons.add),
              label: const Text('Add Bill'),
            )
          : null,
    );
  }
}

/// Pre-configured empty state for search results
class EmptySearchState extends StatelessWidget {
  /// The search query that returned no results
  final String query;

  const EmptySearchState({
    super.key,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.search_off_rounded,
      title: 'No Results Found',
      description: 'No claims match "$query". Try a different search term.',
    );
  }
}
