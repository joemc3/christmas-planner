import 'package:christmas_planner/features/gifts/data/models/gift_model.dart';
import 'package:christmas_planner/features/gifts/presentation/screens/recipient_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 1);
  final gift = GiftModel(
    id: 'g1',
    recipientId: 'r1',
    name: 'Lego Millennium Falcon',
    price: 150,
    actualPrice: 129.99,
    status: GiftStatus.ordered,
    storeName: 'Lego Store',
    expectedDeliveryDate: DateTime(2026, 12, 10),
    createdAt: now,
    updatedAt: now,
  );

  testWidgets('GiftTile shows name, paid price, status and delivery', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GiftTile(gift: gift, onTap: () => tapped = true),
        ),
      ),
    );

    expect(find.text('Lego Millennium Falcon'), findsOneWidget);
    expect(find.text(r'$129.99'), findsOneWidget);
    expect(find.textContaining('Ordered'), findsOneWidget);
    expect(find.textContaining('arrives Dec 10, 2026'), findsOneWidget);

    await tester.tap(find.byType(GiftTile));
    expect(tapped, isTrue);
  });

  test('every gift status has an icon and colour', () {
    for (final s in GiftStatus.values) {
      expect(giftStatusIcon(s), isNotNull);
      expect(giftStatusColor(s), isNotNull);
    }
  });
}
