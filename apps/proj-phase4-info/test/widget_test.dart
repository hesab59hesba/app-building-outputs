import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:build_info_probe/main.dart';

void main() {
  testWidgets('stopwatch renders and toggles start/pause',
      (WidgetTester tester) async {
    await tester.pumpWidget(const StopwatchApp());

    expect(find.text('Stopwatch'), findsOneWidget);
    expect(find.text('00:00.00'), findsOneWidget);
    expect(find.text('Lap'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Start'));
    await tester.pump();

    expect(find.text('Pause'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Start'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Pause'));
    await tester.pump();

    expect(find.text('Start'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Pause'), findsNothing);
  });
}
