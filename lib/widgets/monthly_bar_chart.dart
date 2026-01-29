import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// A custom bar chart widget for displaying monthly trends.
/// Built without external dependencies.
class MonthlyBarChart extends StatefulWidget {
  final Map<String, int> data;
  final double height;
  final Color? barColor;

  const MonthlyBarChart({
    super.key,
    required this.data,
    this.height = 180,
    this.barColor,
  });

  @override
  State<MonthlyBarChart> createState() => _MonthlyBarChartState();
}

class _MonthlyBarChartState extends State<MonthlyBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
        height: widget.height,
        child: const Center(
          child: Text('No data available'),
        ),
      );
    }

    final maxValue = widget.data.values.reduce((a, b) => a > b ? a : b);
    final barColor = widget.barColor ?? AppColors.primary;
    final entries = widget.data.entries.toList();
    
    // Calculate available height for bars (subtract space for label and padding)
    final availableBarHeight = widget.height - 50;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          height: widget.height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate bar width based on available space
              final barWidth = (constraints.maxWidth / entries.length) - 12;
              final clampedBarWidth = barWidth.clamp(20.0, 40.0);
              
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: entries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final monthData = entry.value;
                  final barHeight = maxValue > 0
                      ? (monthData.value / maxValue) * availableBarHeight * _animation.value
                      : 0.0;
                  
                  return Flexible(
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _hoveredIndex = index),
                      onExit: (_) => setState(() => _hoveredIndex = null),
                      child: Tooltip(
                        message: '${monthData.key}: ${monthData.value} claims',
                        child: SizedBox(
                          width: clampedBarWidth + 8,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Value label (only when hovered)
                              SizedBox(
                                height: 18,
                                child: _hoveredIndex == index
                                    ? Text(
                                        '${monthData.value}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: barColor,
                                        ),
                                      )
                                    : null,
                              ),
                              // Bar
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: _hoveredIndex == index ? clampedBarWidth + 4 : clampedBarWidth,
                                height: barHeight.clamp(4.0, availableBarHeight),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      barColor,
                                      barColor.withOpacity(0.7),
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6),
                                  ),
                                  boxShadow: _hoveredIndex == index
                                      ? [
                                          BoxShadow(
                                            color: barColor.withOpacity(0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Month label
                              Text(
                                monthData.key.split(' ')[0].substring(0, 3),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _hoveredIndex == index
                                      ? barColor
                                      : Colors.grey.shade600,
                                  fontWeight: _hoveredIndex == index
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        );
      },
    );
  }
}
