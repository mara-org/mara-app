import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/models/health/daily_water_intake_entry.dart';
import '../../../../core/theme/app_colors.dart';

/// Chart widget displaying water intake trend over time.
class WaterChart extends StatelessWidget {
  final List<DailyWaterIntakeEntry> entries;
  final int days;

  const WaterChart({
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
    final sortedEntries = List<DailyWaterIntakeEntry>.from(entries)
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
      child: BarChart(
        BarChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
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
                interval: 1,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}L',
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
          minY: 0,
          maxY: _getMaxWater(filteredEntries) * 1.2,
          barGroups: filteredEntries.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.waterLiters,
                  color: AppColors.languageButtonColor,
                  width: 12,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  double _getMaxWater(List<DailyWaterIntakeEntry> entries) {
    if (entries.isEmpty) return 4;
    return entries.map((e) => e.waterLiters).reduce((a, b) => a > b ? a : b);
  }
}

