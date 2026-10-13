import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'frosted_widgets.dart';

/// Hosts the five tab branches (home, gifts, meals, shop, events) behind a
/// single persistent navigation bar. Each branch keeps its own stack, so
/// switching tabs never piles screens on top of each other.
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      // Tapping the already-selected tab pops that tab back to its root.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        child: HearthNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: _onTap,
        ),
      ),
    );
  }
}
