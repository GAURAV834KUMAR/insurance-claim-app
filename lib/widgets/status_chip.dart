import 'package:flutter/material.dart';
import '../models/claim_status.dart';
import '../utils/constants.dart';

/// A modern color-coded chip widget for displaying claim status.
/// Features glassmorphism, subtle animations, and premium styling.
class StatusChip extends StatefulWidget {
  final ClaimStatus status;
  final bool showIcon;
  final StatusChipSize size;

  const StatusChip({
    super.key,
    required this.status,
    this.showIcon = true,
    this.size = StatusChipSize.medium,
  });

  @override
  State<StatusChip> createState() => _StatusChipState();
}

class _StatusChipState extends State<StatusChip> 
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Only pulse for active statuses
    if (widget.status == ClaimStatus.submitted || 
        widget.status == ClaimStatus.partiallysettled) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getStatusColor(widget.status);
    final icon = AppColors.getStatusIcon(widget.status);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final double fontSize;
    final double iconSize;
    final EdgeInsets padding;
    final double borderRadius;

    switch (widget.size) {
      case StatusChipSize.small:
        fontSize = 9;
        iconSize = 11;
        padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
        borderRadius = 6;
        break;
      case StatusChipSize.medium:
        fontSize = 11;
        iconSize = 13;
        padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5);
        borderRadius = 8;
        break;
      case StatusChipSize.large:
        fontSize = 13;
        iconSize = 15;
        padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 7);
        borderRadius = 10;
        break;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(isDark ? 0.25 : 0.18),
                  color.withOpacity(isDark ? 0.15 : 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: color.withOpacity(_isHovered ? 0.5 : 0.35),
                width: 1,
              ),
              boxShadow: [
                if (_isHovered || _pulseController.isAnimating)
                  BoxShadow(
                    color: color.withOpacity(0.2 + (_pulseAnimation.value * 0.1)),
                    blurRadius: 8 + (_pulseAnimation.value * 4),
                    spreadRadius: -2,
                  ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.showIcon) ...[
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      icon,
                      size: iconSize,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
                Text(
                  widget.status.displayName,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Size variants for the status chip
enum StatusChipSize {
  small,
  medium,
  large,
}
