import 'package:christmas_planner/core/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  test('three tabs are registered, in order, with their paths', () {
    expect(appModules.map((m) => m.id), ['home', 'gifts', 'meals']);
    expect(appModules.map((m) => m.path), ['/home', '/gifts', '/meals']);
    expect(appModules.map((m) => m.label), ['Home', 'Gifts', 'Meals']);
  });

  test("each module's first route is its tab path", () {
    final key = GlobalKey<NavigatorState>();
    for (final m in appModules) {
      final routes = m.routes(key);
      expect(routes, isNotEmpty);
      expect((routes.first as GoRoute).path, m.path);
    }
  });

  test('every module provides a bar and a rail destination', () {
    for (final m in appModules) {
      expect(m.destination.label, m.label);
      expect((m.railDestination.label as Text).data, m.label);
    }
  });
}
