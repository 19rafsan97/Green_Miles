import 'package:flutter/material.dart';
import 'package:green_miles_app/view/home/home_screen.dart';
import 'package:green_miles_app/view/leaderboard/leaderboard_screen.dart';
import 'package:green_miles_app/view/market/market_screen.dart';
import 'package:green_miles_app/view/profile/profile_screen.dart';
import 'package:green_miles_app/view/tracking/tracking_screen.dart';
import 'package:green_miles_app/view/widgets/custom_bottom_nav.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    LeaderboardScreen(),
    TrackingScreen(),
    MarketScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
      ),
    );
  }
}

