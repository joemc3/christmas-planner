import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/modules/app_module.dart';
import 'presentation/screens/gift_screen.dart';
import 'presentation/screens/gifts_screen.dart';
import 'presentation/screens/recipient_screen.dart';

class GiftsModule extends AppModule {
  @override
  String get id => 'gifts';
  @override
  String get label => 'Gifts';
  @override
  IconData get icon => Icons.redeem_outlined;
  @override
  IconData get selectedIcon => Icons.redeem_rounded;

  @override
  List<RouteBase> routes(GlobalKey<NavigatorState> rootNavigatorKey) => [
    GoRoute(
      path: path,
      builder: (_, _) => const GiftsScreen(),
      routes: [
        GoRoute(
          path: ':recipientId',
          builder: (_, state) => RecipientScreen(
            recipientId: state.pathParameters['recipientId']!,
          ),
          routes: [
            GoRoute(
              path: 'gift/:giftId',
              builder: (_, state) => GiftScreen(
                recipientId: state.pathParameters['recipientId']!,
                giftId: state.pathParameters['giftId']!,
              ),
            ),
          ],
        ),
      ],
    ),
  ];
}
