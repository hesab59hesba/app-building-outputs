import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mood_day/main.dart';

void main() {
  testWidgets('app renders the 30-day mood grid', (tester) async {
    await tester.pumpWidget(const MoodDayApp());

    expect(find.text('Mood Day'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
    expect(find.textContaining('days logged'), findsOneWidget);
  });
}
