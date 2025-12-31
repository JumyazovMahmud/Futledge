import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../service/connectivity_service.dart';
import 'home_screen.dart';
import 'matches_screen.dart';
import 'leagues_screen.dart';
import 'search_screen.dart';
import 'analytics_screen.dart';
import '../widgets/no_internet_overlay.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MatchesScreen(),
    const LeaguesScreen(),
    const SearchScreen(),
    const AnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, child) {
        return Stack(
          children: [
            Scaffold(
              body: _screens[_selectedIndex],
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) => setState(() => _selectedIndex = index),
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.grey,
                backgroundColor: Colors.black,
                selectedFontSize: 12,
                unselectedFontSize: 12,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.sports_soccer_outlined),
                    activeIcon: Icon(Icons.sports_soccer),
                    label: 'Matches',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.emoji_events_outlined),
                    activeIcon: Icon(Icons.emoji_events),
                    label: 'Leagues',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search_outlined),
                    activeIcon: Icon(Icons.search),
                    label: 'Search',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.bar_chart_outlined),
                    activeIcon: Icon(Icons.bar_chart),
                    label: 'Analytics',
                  ),
                ],
              ),
            ),

            // Global No Internet Overlay
            if (!connectivity.hasInternet)
              const NoInternetOverlay(),
          ],
        );
      },
    );
  }
}