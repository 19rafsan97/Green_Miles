import 'package:flutter/material.dart';
import 'package:green_miles_app/core/app_strings.dart';
import 'package:green_miles_app/view/profile/edit_profile_screen.dart';
import 'package:green_miles_app/view/settings/settings_screen.dart';
import 'package:green_miles_app/viewmodel/profile_viewmodel.dart';
import 'package:provider/provider.dart';

import 'package:green_miles_app/view/widgets/section_header.dart';

import 'widgets/profile_header.dart';
import 'widgets/stats_card.dart';
import 'widgets/trip_history_list.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.user == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  viewModel.error ?? 'No profile data available.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final user = viewModel.user!;

          return ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              const SizedBox(height: 20),
              ProfileHeader(user: user),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StatsCard(user: user),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SectionHeader(
                  title: AppStrings.tripHistory,
                  actionLabel: AppStrings.viewTripHistory,
                  onAction: () {
                    // TODO: navigate to full history
                  },
                ),
              ),
              const SizedBox(height: 10),
              TripHistoryList(trips: viewModel.tripHistory),
            ],
          );
        },
      ),
    );
  }
}
