import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/models/health/daily_sleep_entry.dart';
import '../../../../core/theme/app_colors.dart';

/// Chart widget displaying sleep trend over time.
class SleepChart extends StatelessWidget {
  final List<DailySleepEntry> entries;
  final int days;

  const SleepChart({
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
    final sortedEntries = List<DailySleepEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Get last N days worth of data
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final filteredEntries = sortedEntries
        .where((entry) =>
            entry.date.isAfter(startDate) ||
            entry.date.isAtSameMomentAs(startDate))
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
            horizontalInterval: 2,
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
                reservedSize: 40,
                interval: 2,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}h',
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
          maxY: 12,
          lineBarsData: [
            LineChartBarData(
              spots: filteredEntries.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.hours);
              }).toList(),
              isCurved: true,
              color: AppColors.languageButtonColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.languageButtonColor.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
