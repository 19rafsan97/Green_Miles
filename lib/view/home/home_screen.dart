import 'package:flutter/material.dart';
import 'package:green_miles_app/core/app_strings.dart';
import 'package:green_miles_app/core/app_theme.dart';
import 'package:green_miles_app/view/notifications/notifications_screen.dart';
import 'package:green_miles_app/view/widgets/brand_logo.dart';
import 'package:green_miles_app/view/widgets/app_drawer.dart';
import 'package:green_miles_app/viewmodel/home_viewmodel.dart';
import 'package:provider/provider.dart';

import 'widgets/carbon_chart.dart';
import 'widgets/co2_progress_indicator.dart';
import 'package:green_miles_app/view/widgets/section_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const BrandLogo(height: 28),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu_rounded, color: AppTheme.primaryColor),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.notifications_rounded, color: AppTheme.primaryColor),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return RefreshIndicator(
            onRefresh: viewModel.fetchDashboardData,
            color: AppTheme.primaryColor,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${AppStrings.homeGreeting} ${viewModel.user?.name ?? ''}!',
                        style: textTheme.headlineSmall?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Keep building eco streaks today.',
                        style: textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.workspace_premium_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${viewModel.user?.points ?? 0} ${AppStrings.points}',
                              style: textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- CO2 Saved Progress Card ---
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        SectionHeader(
                          title: AppStrings.co2SavedThisWeek,
                          actionLabel: AppStrings.viewTripHistory,
                          onAction: () {
                            // TODO: navigate to trip history when implemented
                          },
                        ),
                        const SizedBox(height: 12),
                        Co2ProgressIndicator(
                          co2Saved: viewModel.weeklyCo2Saved,
                          goal: 20, // Example goal
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- Daily Stats Chart Card ---
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
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 200,
                          child: CarbonChart(stats: viewModel.dailyStats),
                        ),
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
