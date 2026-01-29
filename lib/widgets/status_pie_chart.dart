import 'package:flutter/material.dart';
import '../models/claim_analytics.dart';
import '../utils/constants.dart';

/// A custom pie chart widget that displays status distribution.
/// Built from scratch without external dependencies.
class StatusPieChart extends StatefulWidget {
  final List<StatusDistribution> data;
  final double size;

  const StatusPieChart({
    super.key,
    required this.data,
    this.size = 200,
  });

  @override
  State<StatusPieChart> createState() => _StatusPieChartState();
}

class _StatusPieChartState extends State<StatusPieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Center(
          child: Text(
            'No data',
            style: TextStyle(color: Colors.grey.shade400),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _PieChartPainter(
                data: widget.data,
                progress: _animation.value,
                hoveredIndex: _hoveredIndex,
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        _buildLegend(),
      ],
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: widget.data.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredIndex = index),
          onExit: (_) => setState(() => _hoveredIndex = null),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _hoveredIndex == index
                  ? AppColors.statusColors[item.status]?.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.statusColors[item.status],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${item.status.displayName} (${item.count})',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: _hoveredIndex == index
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<StatusDistribution> data;
  final double progress;
  final int? hoveredIndex;

  _PieChartPainter({
    required this.data,
    required this.progress,
    this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    
    double startAngle = -3.14159 / 2; // Start from top
    final total = data.fold<double>(0, (sum, item) => sum + item.percentage);
    
    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final sweepAngle = (item.percentage / total) * 2 * 3.14159 * progress;
      
      final isHovered = hoveredIndex == i;
      final currentRadius = isHovered ? radius + 8 : radius;
      
      final paint = Paint()
        ..color = AppColors.statusColors[item.status] ?? Colors.grey
        ..style = PaintingStyle.fill;

      // Draw shadow for hovered segment
      if (isHovered) {
        final shadowPaint = Paint()
          ..color = Colors.black.withOpacity(0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: currentRadius),
          startAngle,
          sweepAngle,
          true,
          shadowPaint,
        );
      }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: currentRadius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw segment border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: currentRadius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      startAngle += sweepAngle;
    }

    // Draw center circle (donut hole)
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.5, centerPaint);

    // Draw center text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${data.fold<int>(0, (sum, item) => sum + item.count)}',
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2 + 8),
    );

    final labelPainter = TextPainter(
      text: const TextSpan(
        text: 'Total',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    labelPainter.layout();
    labelPainter.paint(
      canvas,
      center - Offset(labelPainter.width / 2, -8),
    );
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.progress != progress || 
           oldDelegate.hoveredIndex != hoveredIndex;
  }
}
