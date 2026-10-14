import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/layout/breakpoints.dart';
import 'core/router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';

class ChristmasPlannerApp extends ConsumerWidget {
  const ChristmasPlannerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final mode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Christmas Planner',
      debugShowCheckedModeBanner: false,
      themeMode: mode,
      theme: buildTheme(brightness: Brightness.light),
      darkTheme: buildTheme(brightness: Brightness.dark),
      routerConfig: router,
      builder: (context, child) {
        // Larger title sizes on a laptop-width window (design type table).
        final laptop = WindowSize.of(context).isAtLeastMedium;
        if (!laptop) return child!;
        final brightness = Theme.of(context).brightness;
        return Theme(
          data: buildTheme(brightness: brightness, laptop: true),
          child: child!,
        );
      },
    );
  }
}
