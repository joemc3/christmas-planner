import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/modules/app_module.dart';
import 'presentation/screens/home_screen.dart';

class HomeModule extends AppModule {
  @override
  String get id => 'home';
  @override
  String get label => 'Home';
  @override
  IconData get icon => Icons.home_outlined;
  @override
  IconData get selectedIcon => Icons.home_rounded;

  @override
  List<RouteBase> routes(GlobalKey<NavigatorState> rootNavigatorKey) => [
    GoRoute(path: path, builder: (_, _) => const HomeScreen()),
  ];
}
