import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clock_app/main.dart';

void main() {
  Future<void> openTab(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(of: find.byType(NavigationBar), matching: find.text(label)),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('clock app renders all four tabs', (tester) async {
    await tester.pumpWidget(const ClockApp());
    await tester.pump();

    expect(find.text('Local time'), findsOneWidget);

    await openTab(tester, 'Alarms');
    expect(find.text('No alarms yet'), findsOneWidget);

    await openTab(tester, 'Timer');
    final timerText = tester.widget<Text>(find.byKey(const ValueKey<String>('timer-display')));
    expect(timerText.data, '05:00');

    await openTab(tester, 'Stopwatch');
    final stopwatchText =
        tester.widget<Text>(find.byKey(const ValueKey<String>('stopwatch-display')));
    expect(stopwatchText.data, '00:00.00');

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
