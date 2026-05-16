import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:green_miles_app/core/app_strings.dart';
import 'package:green_miles_app/core/app_theme.dart';
import 'package:green_miles_app/data/models/carbon_stat_model.dart';
import 'package:green_miles_app/data/models/trip_model.dart';
import 'package:green_miles_app/view/home/widgets/carbon_chart.dart';
import 'package:green_miles_app/view/widgets/section_header.dart';
import 'package:green_miles_app/viewmodel/home_viewmodel.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  static const double _weeklyGoalKg = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.statistics),
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          final computed = _ComputedStats.from(viewModel.dailyStats);

          if (viewModel.isLoading && computed.stats.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null && computed.stats.isEmpty) {
            return _StatisticsMessageState(
              message: viewModel.error!,
              onRetry: viewModel.fetchDashboardData,
            );
          }

          if (computed.stats.isEmpty) {
            return RefreshIndicator(
              onRefresh: viewModel.fetchDashboardData,
              color: AppTheme.primaryColor,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 60),
                  _StatisticsEmptyState(),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: viewModel.fetchDashboardData,
            color: AppTheme.primaryColor,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _GoalProgressCard(
                  weeklySaved: viewModel.weeklyCo2Saved,
                  weeklyGoal: _weeklyGoalKg,
                ),
                const SizedBox(height: 16),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: AppStrings.statsOverview,
                          actionLabel: null,
                          onAction: null,
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final itemWidth = (constraints.maxWidth - 10) / 2;
                            return Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                SizedBox(
                                  width: itemWidth,
                                  child: _OverviewChip(
                                    icon: Icons.calendar_view_week_rounded,
                                    label: AppStrings.weeklyTotal,
                                    value: '${computed.totalWeek.toStringAsFixed(1)} ${AppStrings.kg}',
                                  ),
                                ),
                                SizedBox(
                                  width: itemWidth,
                                  child: _OverviewChip(
                                    icon: Icons.timeline_rounded,
                                    label: AppStrings.averagePerDay,
                                    value: '${computed.averagePerDay.toStringAsFixed(1)} ${AppStrings.kg}',
                                  ),
                                ),
                                SizedBox(
                                  width: itemWidth,
                                  child: _OverviewChip(
                                    icon: Icons.local_fire_department_outlined,
                                    label: AppStrings.activeDays,
                                    value: '${computed.activeDays}',
                                  ),
                                ),
                                SizedBox(
                                  width: itemWidth,
                                  child: _OverviewChip(
                                    icon: Icons.emoji_events_outlined,
                                    label: AppStrings.bestDay,
                                    value: '${DateFormat('EEE').format(computed.bestDay.date)} ${computed.bestDay.co2Saved.toStringAsFixed(1)} ${AppStrings.kg}',
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: AppStrings.dailyStats,
                          actionLabel: null,
                          onAction: null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          computed.trendText,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.subtitleTextColor,
                              ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 220,
                          child: CarbonChart(stats: computed.stats),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: AppStrings.transportBreakdown,
                          actionLabel: null,
                          onAction: null,
                        ),
                        const SizedBox(height: 12),
                        ...computed.modeBreakdown.map((modeStat) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ModeBreakdownRow(modeStat: modeStat),
                          );
                        }),
                      ],
                    ),
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

class _OverviewChip extends StatelessWidget {
  const _OverviewChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(color: AppTheme.subtitleTextColor),
          ),
        ],
      ),
    );
  }
}

class _GoalProgressCard extends StatelessWidget {
  const _GoalProgressCard({
    required this.weeklySaved,
    required this.weeklyGoal,
  });

  final double weeklySaved;
  final double weeklyGoal;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final progress = (weeklySaved / weeklyGoal).clamp(0.0, 1.0);
    final remaining = math.max(0.0, weeklyGoal - weeklySaved);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.co2SavedThisWeek,
            style: textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${weeklySaved.toStringAsFixed(1)} / ${weeklyGoal.toStringAsFixed(0)} ${AppStrings.kg}',
            style: textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            remaining == 0
                ? 'Goal reached. Great work this week!'
                : '${remaining.toStringAsFixed(1)} ${AppStrings.kg} left to hit your weekly goal',
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeBreakdownRow extends StatelessWidget {
  const _ModeBreakdownRow({required this.modeStat});

  final _ModeBreakdown modeStat;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(_transportIcon(modeStat.mode), color: AppTheme.primaryColor, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _transportLabel(modeStat.mode),
                      style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    '${modeStat.value.toStringAsFixed(1)} ${AppStrings.kg}',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: modeStat.share,
                  minHeight: 8,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.secondaryColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _transportIcon(TransportMode mode) {
    switch (mode) {
      case TransportMode.walk:
        return Icons.directions_walk_rounded;
      case TransportMode.bicycle:
        return Icons.directions_bike_rounded;
      case TransportMode.eScooter:
        return Icons.electric_scooter_rounded;
      case TransportMode.eBike:
        return Icons.pedal_bike_rounded;
      case TransportMode.bus:
        return Icons.directions_bus_rounded;
      case TransportMode.publicTransport:
        return Icons.directions_bus_rounded;
      case TransportMode.electricVehicle:
        return Icons.electric_car_rounded;
      case TransportMode.car:
        return Icons.directions_car_rounded;
    }
  }

  String _transportLabel(TransportMode mode) {
    switch (mode) {
      case TransportMode.walk:
        return AppStrings.walk;
      case TransportMode.bicycle:
        return AppStrings.bicycle;
      case TransportMode.publicTransport:
      case TransportMode.bus:
        return AppStrings.publicTransport;
      case TransportMode.electricVehicle:
        return AppStrings.electricVehicle;
      case TransportMode.car:
        return AppStrings.car;
      case TransportMode.eScooter:
        return 'E-Scooter';
      case TransportMode.eBike:
        return 'E-Bike';
    }
  }
}

class _StatisticsEmptyState extends StatelessWidget {
  const _StatisticsEmptyState();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        children: [
          const Icon(
            Icons.query_stats_rounded,
            size: 46,
            color: AppTheme.subtitleTextColor,
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.noStatsYet,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _ComputedStats {
  _ComputedStats({required this.stats});

  factory _ComputedStats.from(List<CarbonStatModel> rawStats) {
    final sorted = [...rawStats]..sort((a, b) => a.date.compareTo(b.date));
    return _ComputedStats(stats: sorted);
  }

  final List<CarbonStatModel> stats;

  double get totalWeek => stats.fold<double>(0, (sum, item) => sum + item.co2Saved);

  double get averagePerDay => stats.isEmpty ? 0 : totalWeek / stats.length;

  int get activeDays => stats.where((item) => item.co2Saved > 0).length;

  CarbonStatModel get bestDay {
    return stats.reduce((a, b) => a.co2Saved >= b.co2Saved ? a : b);
  }

  String get trendText {
    if (stats.length < 4) {
      return 'Track more days to unlock trend insights.';
    }

    final half = stats.length ~/ 2;
    final firstHalfAvg = stats.take(half).fold<double>(0, (sum, item) => sum + item.co2Saved) / half;
    final secondHalfCount = stats.length - half;
    final secondHalfAvg = stats.skip(half).fold<double>(0, (sum, item) => sum + item.co2Saved) / secondHalfCount;
    final diff = secondHalfAvg - firstHalfAvg;

    if (diff > 0.2) {
      return 'You are trending up by ${diff.toStringAsFixed(1)} ${AppStrings.kg} per day.';
    }
    if (diff < -0.2) {
      return 'You are trending down by ${diff.abs().toStringAsFixed(1)} ${AppStrings.kg} per day.';
    }
    return 'Your daily impact is steady this week.';
  }

  List<_ModeBreakdown> get modeBreakdown {
    final byMode = <TransportMode, double>{};
    for (final stat in stats) {
      byMode.update(stat.mode, (value) => value + stat.co2Saved, ifAbsent: () => stat.co2Saved);
    }

    if (byMode.isEmpty) {
      return [];
    }

    final total = totalWeek;
    final rows = byMode.entries
        .map(
          (entry) => _ModeBreakdown(
            mode: entry.key,
            value: entry.value,
            share: total == 0 ? 0 : entry.value / total,
          ),
        )
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return rows;
  }
}

class _ModeBreakdown {
  const _ModeBreakdown({
    required this.mode,
    required this.value,
    required this.share,
  });

  final TransportMode mode;
  final double value;
  final double share;
}

class _StatisticsMessageState extends StatelessWidget {
  const _StatisticsMessageState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: AppTheme.subtitleTextColor),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}




