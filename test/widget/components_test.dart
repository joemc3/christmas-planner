import 'package:christmas_planner/core/domain/money.dart';
import 'package:christmas_planner/core/domain/statuses.dart';
import 'package:christmas_planner/core/theme/app_theme.dart';
import 'package:christmas_planner/features/gifts/presentation/widgets/rows.dart';
import 'package:christmas_planner/shared/widgets/money_triple_view.dart';
import 'package:christmas_planner/shared/widgets/status_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Widget host(Widget child) => MaterialApp(
  theme: buildTheme(brightness: Brightness.light),
  home: Scaffold(body: Center(child: child)),
);

class _G implements GiftLike {
  _G(this.price, this.status);
  @override
  final double price;
  @override
  final GiftStatus status;
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('GiftsTotalLine', () {
    testWidgets('no master budget reads as unset, never over', (tester) async {
      final money = giftMoney([
        _G(1.5, GiftStatus.purchased),
        _G(500, GiftStatus.purchased),
      ], budget: 0);
      await tester.pumpWidget(
        host(GiftsTotalLine(money: money, currency: 'USD')),
      );
      expect(
        find.textContaining('No gift budget yet', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining(r'$501.50 spent', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining('2 of 2 bought', findRichText: true),
        findsOneWidget,
      );
      expect(find.textContaining('over', findRichText: true), findsNothing);
    });

    testWidgets('with a budget reads remaining, and over when spent past it', (
      tester,
    ) async {
      final under = giftMoney([_G(18, GiftStatus.purchased)], budget: 600);
      await tester.pumpWidget(
        host(GiftsTotalLine(money: under, currency: 'USD')),
      );
      expect(
        find.textContaining(r'$582.00 left of $600.00', findRichText: true),
        findsOneWidget,
      );
      final over = giftMoney([_G(650, GiftStatus.purchased)], budget: 600);
      await tester.pumpWidget(
        host(GiftsTotalLine(money: over, currency: 'USD')),
      );
      expect(
        find.textContaining(r'$50.00 over budget $600.00', findRichText: true),
        findsOneWidget,
      );
    });
  });

  group('MoneyTripleView', () {
    testWidgets('large form leads with remaining', (tester) async {
      final money = giftMoney([
        _G(129, GiftStatus.ordered),
        _G(24.99, GiftStatus.toBuy),
      ], budget: 150);
      await tester.pumpWidget(
        host(MoneyTripleView(money: money, currency: 'USD')),
      );
      expect(find.text('Left to spend'), findsOneWidget);
      expect(find.text(r'$21.00'), findsOneWidget);
      expect(find.text(r'$129.00'), findsOneWidget);
      expect(find.text(r'$150.00'), findsOneWidget);
      expect(find.text('Over budget'), findsNothing);
    });

    testWidgets('over budget changes the words and adds a tag', (tester) async {
      final money = giftMoney([_G(112, GiftStatus.purchased)], budget: 100);
      await tester.pumpWidget(
        host(MoneyTripleView(money: money, currency: 'USD')),
      );
      expect(find.text(r'$12.00 over'), findsOneWidget);
      expect(find.text('Over budget'), findsNWidgets(2));
      expect(find.text('Left to spend'), findsNothing);
    });

    testWidgets('compact form reads "left of"', (tester) async {
      final money = giftMoney([_G(129, GiftStatus.ordered)], budget: 150);
      await tester.pumpWidget(
        host(
          SizedBox(
            width: 300,
            child: MoneyTripleView(
              money: money,
              currency: 'USD',
              size: MoneySize.compact,
            ),
          ),
        ),
      );
      expect(
        find.textContaining(r'$21.00', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining(r'left of $150.00', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('zero budget with a setter shows the set-budget button', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          MoneyTripleView(
            money: MoneyTriple.empty,
            currency: 'USD',
            onSetBudget: () {},
          ),
        ),
      );
      expect(find.text('No budget set yet'), findsOneWidget);
      expect(find.text('Set budget'), findsOneWidget);
    });
  });

  group('GiftStepperRow', () {
    testWidgets('a later cell moves forward, an earlier cell does nothing', (
      tester,
    ) async {
      final taps = <GiftStatus>[];
      await tester.pumpWidget(
        host(GiftStepperRow(status: GiftStatus.ordered, onForward: taps.add)),
      );
      await tester.tap(find.bySemanticsLabel('Mark Purchased'));
      await tester.tap(find.bySemanticsLabel('To Buy'));
      expect(taps, [GiftStatus.purchased]);
    });

    testWidgets('To Buy can skip straight to Purchased', (tester) async {
      final taps = <GiftStatus>[];
      await tester.pumpWidget(
        host(GiftStepperRow(status: GiftStatus.toBuy, onForward: taps.add)),
      );
      await tester.tap(find.bySemanticsLabel('Mark Purchased'));
      expect(taps, [GiftStatus.purchased]);
    });

    testWidgets('disabled rows take no taps', (tester) async {
      final taps = <GiftStatus>[];
      await tester.pumpWidget(
        host(
          GiftStepperRow(
            status: GiftStatus.toBuy,
            onForward: taps.add,
            enabled: false,
          ),
        ),
      );
      expect(find.bySemanticsLabel('Mark Purchased'), findsNothing);
      expect(find.bySemanticsLabel('Purchased'), findsOneWidget);
      expect(taps, isEmpty);
    });

    testWidgets('cells are 44 px touch targets', (tester) async {
      await tester.pumpWidget(
        host(GiftStepperRow(status: GiftStatus.toBuy, onForward: (_) {})),
      );
      final size = tester.getSize(find.bySemanticsLabel('Mark Ordered'));
      expect(size.width, 44);
      expect(size.height, 44);
    });
  });

  group('MealItemStepperRow', () {
    testWidgets('has two cells', (tester) async {
      final taps = <MealItemStatus>[];
      await tester.pumpWidget(
        host(
          MealItemStepperRow(status: MealItemStatus.toBuy, onForward: taps.add),
        ),
      );
      await tester.tap(find.bySemanticsLabel('Mark Purchased'));
      expect(taps, [MealItemStatus.purchased]);
      expect(find.bySemanticsLabel('Mark Ordered'), findsNothing);
    });
  });
}
