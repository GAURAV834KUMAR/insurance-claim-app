import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/models.dart';
import '../utils/utils.dart';
import 'status_chip.dart';

/// A premium modern card widget for displaying claim summary.
/// Features glassmorphism, gradients, and interactive animations.
class ClaimCard extends StatefulWidget {
  final Claim claim;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ClaimCard({
    super.key,
    required this.claim,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<ClaimCard> createState() => _ClaimCardState();
}

class _ClaimCardState extends State<ClaimCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.01).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHoverChanged(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = AppColors.getStatusColor(widget.claim.status);
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 450;
    
    return MouseRegion(
      onEnter: (_) => _onHoverChanged(true),
      onExit: (_) => _onHoverChanged(false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _isHovered 
                        ? statusColor.withOpacity(0.15)
                        : Colors.black.withOpacity(isDark ? 0.25 : 0.06),
                    blurRadius: _isHovered ? 24 : 16,
                    offset: Offset(0, _isHovered ? 10 : 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                const Color(0xFF252538),
                                const Color(0xFF1C1C2D),
                              ]
                            : [
                                Colors.white,
                                const Color(0xFFFAFBFC),
                              ],
                      ),
                      border: Border.all(
                        color: _isHovered
                            ? statusColor.withOpacity(0.4)
                            : (isDark ? const Color(0xFF3A3A4D) : const Color(0xFFE8EDF3)),
                        width: _isHovered ? 1.5 : 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.onTap,
                        borderRadius: BorderRadius.circular(20),
                        splashColor: statusColor.withOpacity(0.1),
                        highlightColor: statusColor.withOpacity(0.05),
                        child: Column(
                          children: [
                            // Top gradient accent
                            Container(
                              height: 4,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                gradient: LinearGradient(
                                  colors: [
                                    statusColor,
                                    statusColor.withOpacity(0.5),
                                    statusColor.withOpacity(0.3),
                                  ],
                                ),
                              ),
                            ),
                            
                            Padding(
                              padding: EdgeInsets.all(isCompact ? 14 : 18),
                              child: Column(
                                children: [
                                  // Header section
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Avatar with animated ring
                                      _buildAvatar(statusColor, isDark, isCompact),
                                      SizedBox(width: isCompact ? 12 : 16),
                                      
                                      // Patient info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.claim.patientName,
                                              style: TextStyle(
                                                fontSize: isCompact ? 16 : 18,
                                                fontWeight: FontWeight.w700,
                                                color: isDark ? Colors.white : const Color(0xFF1A1D29),
                                                letterSpacing: -0.3,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            // Info badges row
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 6,
                                              children: [
                                                _buildInfoBadge(
                                                  icon: Icons.assignment_outlined,
                                                  text: widget.claim.policyNumber,
                                                  isDark: isDark,
                                                  isCompact: isCompact,
                                                ),
                                                _buildInfoBadge(
                                                  icon: Icons.event_rounded,
                                                  text: Formatters.formatShortDate(widget.claim.claimDate),
                                                  isDark: isDark,
                                                  isCompact: isCompact,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Status chip
                                      StatusChip(status: widget.claim.status),
                                    ],
                                  ),
                                  
                                  SizedBox(height: isCompact ? 14 : 18),
                                  
                                  // Amount cards section
                                  _buildAmountSection(isDark, isCompact),
                                  
                                  // Action buttons
                                  if (widget.claim.isEditable && 
                                      (widget.onEdit != null || widget.onDelete != null)) ...[
                                    const SizedBox(height: 14),
                                    _buildActionButtons(isDark, isCompact),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(Color statusColor, bool isDark, bool isCompact) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColor,
            statusColor.withOpacity(0.5),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: isDark ? const Color(0xFF1E1E2D) : Colors.white,
        radius: isCompact ? 20 : 24,
        child: Text(
          widget.claim.patientName.isNotEmpty
              ? widget.claim.patientName[0].toUpperCase()
              : '?',
          style: TextStyle(
            fontSize: isCompact ? 16 : 20,
            fontWeight: FontWeight.w700,
            color: statusColor,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBadge({
    required IconData icon,
    required String text,
    required bool isDark,
    required bool isCompact,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2D2D40), const Color(0xFF252535)]
              : [const Color(0xFFF1F5F9), const Color(0xFFE8EDF3)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark 
              ? Colors.white.withOpacity(0.08) 
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isCompact ? 11 : 13,
            color: isDark ? Colors.white54 : const Color(0xFF64748B),
          ),
          SizedBox(width: isCompact ? 4 : 5),
          Text(
            text,
            style: TextStyle(
              fontSize: isCompact ? 10 : 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection(bool isDark, bool isCompact) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF2A2A3E), const Color(0xFF222232)]
              : [const Color(0xFFF8FAFC), const Color(0xFFF1F5F9)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
              ? Colors.white.withOpacity(0.06) 
              : const Color(0xFFE8EDF3),
        ),
      ),
      child: Row(
        children: [
          _buildAmountItem(
            label: 'Total Bill',
            amount: widget.claim.totalBillAmount,
            icon: Icons.receipt_long_rounded,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
            isDark: isDark,
            isCompact: isCompact,
          ),
          _buildDivider(isDark),
          _buildAmountItem(
            label: 'Advance',
            amount: widget.claim.advancePaid,
            icon: Icons.account_balance_wallet_rounded,
            color: const Color(0xFF3B82F6),
            isDark: isDark,
            isCompact: isCompact,
          ),
          _buildDivider(isDark),
          _buildAmountItem(
            label: 'Pending',
            amount: widget.claim.pendingAmount,
            icon: Icons.hourglass_bottom_rounded,
            color: widget.claim.pendingAmount > 0
                ? const Color(0xFFEF4444)
                : const Color(0xFF22C55E),
            isDark: isDark,
            isCompact: isCompact,
          ),
        ],
      ),
    );
  }

  Widget _buildAmountItem({
    required String label,
    required double amount,
    required IconData icon,
    required Color color,
    required bool isDark,
    required bool isCompact,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: isCompact ? 14 : 16, color: color),
          ),
          SizedBox(height: isCompact ? 6 : 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              Formatters.formatCurrency(amount),
              style: TextStyle(
                fontSize: isCompact ? 13 : 15,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: isCompact ? 9 : 10,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 45,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            isDark ? Colors.white12 : const Color(0xFFE2E8F0),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool isDark, bool isCompact) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.onDelete != null)
          _buildActionButton(
            icon: Icons.delete_outline_rounded,
            label: 'Delete',
            color: const Color(0xFFEF4444),
            onTap: widget.onDelete!,
            isDark: isDark,
            isCompact: isCompact,
          ),
        if (widget.onEdit != null) ...[
          const SizedBox(width: 10),
          _buildActionButton(
            icon: Icons.edit_rounded,
            label: 'Edit',
            color: const Color(0xFF3B82F6),
            onTap: widget.onEdit!,
            isDark: isDark,
            isCompact: isCompact,
            isPrimary: true,
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
    required bool isCompact,
    bool isPrimary = false,
  }) {
    return Material(
      color: isPrimary ? color : color.withOpacity(isDark ? 0.15 : 0.1),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 12 : 14,
            vertical: isCompact ? 7 : 9,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: isCompact ? 14 : 16,
                color: isPrimary ? Colors.white : color,
              ),
              SizedBox(width: isCompact ? 5 : 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: isCompact ? 11 : 12,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
