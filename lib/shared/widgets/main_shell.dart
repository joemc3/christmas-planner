import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/modules/app_module.dart';
import 'app_mark.dart';

/// Hosts the tab branches: a bottom NavigationBar below 840 px, a
/// NavigationRail carrying the mark at or above. Destinations come from the
/// registered modules, so a new tab needs no change here.
class MainShell extends StatelessWidget {
  const MainShell({
    super.key,
    required this.navigationShell,
    required this.modules,
  });

  final StatefulNavigationShell navigationShell;
  final List<AppModule> modules;

  void _go(int index) => navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    // The tab screens' own messenger, so a snackbar shows inside the
    // current tab's Scaffold and lifts its floating button, instead of in
    // the shell's Scaffold where it would cover the button.
    final tabs = ScaffoldMessenger(child: navigationShell);

    if (WindowSize.of(context).isCompact) {
      return Scaffold(
        body: tabs,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _go,
          destinations: [for (final m in modules) m.destination],
        ),
      );
    }
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _go,
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: AppMark(size: 40),
            ),
            destinations: [for (final m in modules) m.railDestination],
          ),
          const VerticalDivider(),
          Expanded(child: tabs),
        ],
      ),
    );
  }
}
