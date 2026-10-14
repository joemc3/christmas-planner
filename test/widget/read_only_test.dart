import 'package:christmas_planner/core/theme/app_theme.dart';
import 'package:christmas_planner/features/auth/presentation/providers/auth_provider.dart';
import 'package:christmas_planner/features/gifts/data/models/gift_model.dart';
import 'package:christmas_planner/features/gifts/data/models/recipient_model.dart';
import 'package:christmas_planner/features/gifts/presentation/providers/gift_providers.dart';
import 'package:christmas_planner/features/gifts/presentation/screens/recipient_screen.dart';
import 'package:christmas_planner/features/home/presentation/providers/home_data.dart';
import 'package:christmas_planner/features/plan/data/models/plan_model.dart';
import 'package:christmas_planner/features/plan/presentation/providers/plan_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

final _t = DateTime(2025, 10, 1);

final _plan = PlanModel(
  id: 'p',
  userId: 'u',
  year: 2025,
  giftBudgetTotal: 600,
  createdAt: _t,
  updatedAt: _t,
);

final _mum = RecipientModel(
  id: 'mum',
  planId: 'p',
  name: 'Mum',
  budgetLimit: 150,
  createdAt: _t,
  updatedAt: _t,
);

final _gift = GiftModel(
  id: 'g1',
  recipientId: 'mum',
  name: 'Espresso machine',
  price: 129,
  status: GiftStatus.toBuy,
  createdAt: _t,
  updatedAt: _t,
);

Widget app({required bool readOnly}) => ProviderScope(
  overrides: [
    todayProvider.overrideWithValue(DateTime(2026, 10, 14)),
    selectedPlanProvider.overrideWithValue(AsyncData(_plan)),
    readOnlyProvider.overrideWithValue(readOnly),
    recipientsProvider.overrideWithValue(AsyncData([_mum])),
    giftsProvider.overrideWithValue(AsyncData([_gift])),
    userProfileProvider.overrideWith((ref) async => null),
    homeDataProvider.overrideWithValue(
      AsyncData(
        buildHomeData(
          plan: _plan,
          readOnly: readOnly,
          today: DateTime(2026, 10, 14),
          shippingDays: 7,
          recipients: [_mum],
          gifts: [_gift],
          meals: const [],
          items: const [],
          previousYears: const [],
        ),
      ),
    ),
  ],
  child: MaterialApp(
    theme: buildTheme(brightness: Brightness.light),
    home: const RecipientScreen(recipientId: 'mum', embedded: true),
  ),
);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('a current year offers add, edit, delete and the stepper', (
    tester,
  ) async {
    await tester.pumpWidget(app(readOnly: false));
    await tester.pump();
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byTooltip('Edit person'), findsOneWidget);
    expect(find.byTooltip('Delete person'), findsOneWidget);
    expect(find.bySemanticsLabel('Mark Purchased'), findsOneWidget);
    expect(find.text('Espresso machine'), findsOneWidget);
  });

  testWidgets('a previous year is read-only: no add, edit, delete or taps', (
    tester,
  ) async {
    await tester.pumpWidget(app(readOnly: true));
    await tester.pump();
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.byTooltip('Edit person'), findsNothing);
    expect(find.byTooltip('Delete person'), findsNothing);
    expect(find.bySemanticsLabel('Mark Purchased'), findsNothing);
    expect(find.text('Espresso machine'), findsOneWidget);
  });
}
