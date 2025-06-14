import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/widgets/bottom_nav.dart';
import 'package:frontend/widgets/main_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  testWidgets('App starts and shows the main screen with bottom navigation',
      (WidgetTester tester) async {
    // Setup required initializations, similar to main.dart
    await Hive.initFlutter();
    await Hive.openBox('app_data');

    // Build our app and trigger a frame.
    // The MainScreenWrapper needs to be inside MaterialApp to provide
    // theme, routing, etc. It also needs ProviderScope.
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MainScreen(),
        ),
      ),
    );

    // Wait for any animations or state changes to settle.
    await tester.pumpAndSettle();

    // Verify that the MainScreenWrapper has built correctly by looking for a part of it.
    expect(find.byType(BottomNav), findsOneWidget);
  });
}