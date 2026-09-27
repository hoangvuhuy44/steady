import 'package:flutter/material.dart';

import '../screens/check_in_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/rewards_screen.dart';
import '../state/steady_store.dart';
import '../theme/steady_theme.dart';

class SteadyApp extends StatefulWidget {
  const SteadyApp({super.key});

  @override
  State<SteadyApp> createState() => _SteadyAppState();
}

class _SteadyAppState extends State<SteadyApp> {
  final SteadyStore store = SteadyStore();
  int selectedIndex = 0;

  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Steady',
      theme: SteadyTheme.light(),
      home: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final screens = [
            HomeScreen(
              store: store,
              onCheckIn: () => setState(() => selectedIndex = 1),
            ),
            CheckInScreen(
              store: store,
              onSaved: () => setState(() => selectedIndex = 0),
            ),
            RewardsScreen(store: store),
            ProfileScreen(store: store),
          ];

          return Scaffold(
            body: SafeArea(child: screens[selectedIndex]),
            bottomNavigationBar: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) {
                setState(() => selectedIndex = index);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Today',
                ),
                NavigationDestination(
                  icon: Icon(Icons.add_circle_outline),
                  selectedIcon: Icon(Icons.add_circle),
                  label: 'Check in',
                ),
                NavigationDestination(
                  icon: Icon(Icons.emoji_events_outlined),
                  selectedIcon: Icon(Icons.emoji_events),
                  label: 'Rewards',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
