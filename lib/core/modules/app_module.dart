import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A tab of the app. The router builds its shell branches and the shell its
/// destinations from [appModules], so adding a tab later (a calendar, say)
/// is a new feature folder with its own module and one line in the list.
/// Modules never import each other.
abstract class AppModule {
  /// Stable identifier, also the first path segment: 'home' is '/home'.
  String get id;

  String get label;
  IconData get icon;
  IconData get selectedIcon;

  String get path => '/$id';

  /// This tab's routes; the first must match [path].
  List<RouteBase> routes(GlobalKey<NavigatorState> rootNavigatorKey);

  NavigationDestination get destination => NavigationDestination(
    icon: Icon(icon),
    selectedIcon: Icon(selectedIcon),
    label: label,
  );

  NavigationRailDestination get railDestination => NavigationRailDestination(
    icon: Icon(icon),
    selectedIcon: Icon(selectedIcon),
    label: Text(label),
  );
}
