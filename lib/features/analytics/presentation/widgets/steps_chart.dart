import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/models/health/daily_steps_entry.dart';
import '../../../../core/theme/app_colors.dart';

/// Chart widget displaying steps trend over time.
class StepsChart extends StatelessWidget {
  final List<DailyStepsEntry> entries;
  final int days;

  const StepsChart({
    super.key,
    required this.entries,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort entries by date
    final sortedEntries = List<DailyStepsEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Get last N days worth of data
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final filteredEntries = sortedEntries
        .where((entry) => entry.date.isAfter(startDate) || entry.date.isAtSameMomentAs(startDate))
        .toList();

    if (filteredEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.permissionCardBackground,
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _getMaxSteps(filteredEntries) / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.textSecondary.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: days <= 7 ? 1.0 : (days ~/ 7).toDouble(),
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < filteredEntries.length) {
                    final date = filteredEntries[index].date;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '${date.day}/${date.month}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                interval: _getMaxSteps(filteredEntries) / 4,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${(value / 1000).toStringAsFixed(1)}k',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (filteredEntries.length - 1).toDouble(),
          minY: 0,
          maxY: _getMaxSteps(filteredEntries) * 1.2,
          lineBarsData: [
            LineChartBarData(
              spots: filteredEntries.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.steps.toDouble());
              }).toList(),
              isCurved: true,
              color: AppColors.languageButtonColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.languageButtonColor.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxSteps(List<DailyStepsEntry> entries) {
    if (entries.isEmpty) return 10000;
    return entries.map((e) => e.steps.toDouble()).reduce((a, b) => a > b ? a : b);
  }
}

