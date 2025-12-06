import 'package:flutter/material.dart';

/// A reusable progress bar widget for showing progress toward a goal.
///
/// Displays a progress bar with percentage completion and optional label.
class ProgressBar extends StatelessWidget {
  /// Current value (e.g., steps taken today)
  final double current;

  /// Goal value (e.g., daily steps goal)
  final double goal;

  /// Optional label to display
  final String? label;

  /// Color of the progress bar
  final Color progressColor;

  /// Background color of the progress bar
  final Color backgroundColor;

  /// Height of the progress bar
  final double height;

  /// Whether to show percentage text
  final bool showPercentage;

  const ProgressBar({
    super.key,
    required this.current,
    required this.goal,
    this.label,
    this.progressColor = const Color(0xFF0EA5C6),
    this.backgroundColor = const Color(0xFFE2E8F0),
    this.height = 8.0,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Stack(
          children: [
            Container(
              height: height,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ),
          ],
        ),
        if (showPercentage) ...[
          const SizedBox(height: 4),
          Text(
            '$percentage%',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

