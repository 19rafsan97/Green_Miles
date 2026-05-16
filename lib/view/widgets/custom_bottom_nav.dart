import 'package:flutter/material.dart';
import 'package:green_miles_app/core/app_strings.dart';
import 'package:green_miles_app/core/app_theme.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  const CustomBottomNav({
	super.key,
	required this.currentIndex,
	required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
	return SafeArea(
	  minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
	  child: DecoratedBox(
		decoration: BoxDecoration(
		  gradient: AppTheme.mintGlass,
		  borderRadius: BorderRadius.circular(AppTheme.radiusXL),
		  border: Border.all(color: AppTheme.shadowColor.withValues(alpha: 0.16)),
		  boxShadow: AppTheme.softShadow,
		),
		child: NavigationBar(
		  selectedIndex: currentIndex,
		  onDestinationSelected: onDestinationSelected,
		  destinations: const [
			NavigationDestination(icon: Icon(Icons.home_filled), label: AppStrings.home),
			NavigationDestination(icon: Icon(Icons.leaderboard), label: AppStrings.ranking),
			NavigationDestination(icon: Icon(Icons.route), label: 'Track'),
			NavigationDestination(icon: Icon(Icons.storefront), label: 'Mart'),
			NavigationDestination(icon: Icon(Icons.person), label: AppStrings.profile),
		  ],
		),
	  ),
	);
  }
}


