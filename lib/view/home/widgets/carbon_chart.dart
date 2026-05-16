import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:green_miles_app/core/app_theme.dart';
import 'package:green_miles_app/data/models/carbon_stat_model.dart';
import 'package:intl/intl.dart';

class CarbonChart extends StatelessWidget {
  final List<CarbonStatModel> stats;

  const CarbonChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxY(),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppTheme.primaryColor,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toStringAsFixed(1)} kg',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: _getBottomTitles,
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              getTitlesWidget: _getLeftTitles,
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withValues(alpha: 255 * 0.2),
            strokeWidth: 1,
          ),
        ),
        barGroups: _getBarGroups(),
      ),
    );
  }

  double _getMaxY() {
    if (stats.isEmpty) return 10.0;
    final maxVal = stats.map((s) => s.co2Saved).reduce((a, b) => a > b ? a : b);
    return (maxVal * 1.2).ceilToDouble(); // Add 20% padding
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    final style = TextStyle(
      color: AppTheme.subtitleTextColor,
      fontWeight: FontWeight.w600,
      fontSize: 12,
    );
    Widget text;
    if (value.toInt() < stats.length) {
      final day = DateFormat('E').format(stats[value.toInt()].date); // E.g., "Mon"
      text = Text(day, style: style);
    } else {
      text = Text('', style: style);
    }
    return SideTitleWidget(axisSide: meta.axisSide, child: text);
  }

  Widget _getLeftTitles(double value, TitleMeta meta) {
    if (value == meta.max || value == 0) {
      return Container(); // Hide max and min value
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        '${value.toInt()}',
        style: const TextStyle(color: AppTheme.subtitleTextColor, fontSize: 11),
      ),
    );
  }

  List<BarChartGroupData> _getBarGroups() {
    return List.generate(stats.length, (index) {
      final stat = stats[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: stat.co2Saved,
            color: AppTheme.secondaryColor,
            width: 14,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
        ],
      );
    });
  }
}
