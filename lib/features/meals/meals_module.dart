import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/modules/app_module.dart';
import 'presentation/screens/meal_screen.dart';
import 'presentation/screens/meals_screen.dart';

class MealsModule extends AppModule {
  @override
  String get id => 'meals';
  @override
  String get label => 'Meals';
  @override
  IconData get icon => Icons.restaurant_outlined;
  @override
  IconData get selectedIcon => Icons.restaurant_rounded;

  @override
  List<RouteBase> routes(GlobalKey<NavigatorState> rootNavigatorKey) => [
    GoRoute(
      path: path,
      builder: (_, _) => const MealsScreen(),
      routes: [
        GoRoute(
          path: ':mealId',
          builder: (_, state) =>
              MealScreen(mealId: state.pathParameters['mealId']!),
        ),
      ],
    ),
  ];
}
