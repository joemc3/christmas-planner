import 'package:christmas_planner/core/theme/app_theme.dart';
import 'package:christmas_planner/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget app() => ProviderScope(
    child: MaterialApp(
      theme: buildTheme(brightness: Brightness.light),
      home: const LoginScreen(),
    ),
  );

  testWidgets('shows the title, the one line and the two fields', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    expect(find.text('Christmas Planner'), findsOneWidget);
    expect(
      find.text('Gifts and the two Christmas meals, inside the money.'),
      findsOneWidget,
    );
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
  });

  testWidgets('offers reset and create account, never social sign-in', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    expect(find.text('Forgot your password?'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
    expect(find.textContaining('Google'), findsNothing);
    expect(find.textContaining('Apple'), findsNothing);
  });

  testWidgets('validates before submitting', (tester) async {
    await tester.pumpWidget(app());
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();
    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });
}
