import 'package:flutter/material.dart';
import 'package:green_miles_app/core/app_strings.dart';
import 'package:green_miles_app/core/app_theme.dart';
import 'package:green_miles_app/viewmodel/leaderboard_viewmodel.dart';
import 'package:provider/provider.dart';

import 'widgets/leaderboard_list_item.dart';
import 'widgets/podium_widget.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.leaderboard),
      ),
      body: Consumer<LeaderboardViewModel>(
        builder: (context, viewModel, child) {
          final topThree = viewModel.users.take(3).toList();
          final showPodium = topThree.length >= 3;
          final listedUsers = showPodium ? viewModel.users.skip(3).toList() : viewModel.users;
          final rankStart = showPodium ? 4 : 1;

          return Column(
            children: [
              _buildPeriodSelector(context, viewModel),
              Expanded(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : viewModel.error != null
                    ? _LeaderboardMessageState(
                        message: viewModel.error!,
                        icon: Icons.error_outline,
                        onRetry: viewModel.fetchLeaderboard,
                      )
                    : viewModel.users.isEmpty
                    ? _LeaderboardMessageState(
                        message: AppStrings.leaderboardEmpty,
                        icon: Icons.leaderboard_outlined,
                        onRetry: viewModel.fetchLeaderboard,
                      )
                    : RefreshIndicator(
                        onRefresh: viewModel.fetchLeaderboard,
                        color: AppTheme.primaryColor,
                        child: ListView(
                          padding: const EdgeInsets.only(bottom: 18),
                          children: [
                            SizedBox(height: showPodium ? 24 : 12),
                            if (showPodium)
                              PodiumWidget(
                                topUsers: topThree,
                              ),
                            SizedBox(height: showPodium ? 24 : 8),
                            ...List.generate(listedUsers.length, (index) {
                              final user = listedUsers[index];
                              return LeaderboardListItem(
                                user: user,
                                rank: index + rankStart,
                              );
                            }),
                          ],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context, LeaderboardViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.shadowColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              context,
              text: AppStrings.weekly,
              isSelected: viewModel.selectedPeriod == LeaderboardPeriod.weekly,
              onTap: () => viewModel.setPeriod(LeaderboardPeriod.weekly),
            ),
          ),
          Expanded(
            child: _buildTab(
              context,
              text: AppStrings.monthly,
              isSelected: viewModel.selectedPeriod == LeaderboardPeriod.monthly,
              onTap: () => viewModel.setPeriod(LeaderboardPeriod.monthly),
            ),
          ),
          Expanded(
            child: _buildTab(
              context,
              text: AppStrings.allTime,
              isSelected: viewModel.selectedPeriod == LeaderboardPeriod.allTime,
              onTap: () => viewModel.setPeriod(LeaderboardPeriod.allTime),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, {required String text, required bool isSelected, required VoidCallback onTap}) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            text,
            style: textTheme.titleMedium?.copyWith(
              color: isSelected ? AppTheme.primaryColor : AppTheme.subtitleTextColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _LeaderboardMessageState extends StatelessWidget {
  const _LeaderboardMessageState({
    required this.message,
    required this.icon,
    required this.onRetry,
  });

  final String message;
  final IconData icon;
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
            Icon(icon, size: 40, color: AppTheme.subtitleTextColor),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

