import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:leap_check/main.dart';

void main() {
  testWidgets('renders both tools and checks a leap year', (tester) async {
    await tester.pumpWidget(const LeapCheckApp());

    expect(find.text('Leap Check'), findsOneWidget);
    expect(find.text('Leap Year Checker'), findsOneWidget);
    expect(find.text('Days in a Month'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '2024');
    await tester.tap(find.byType(FilledButton).first);
    await tester.pump();

    expect(find.text('2024 is a leap year (366 days).'), findsOneWidget);
  });
}
