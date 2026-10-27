import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chess_clock/main.dart';

void main() {
  testWidgets('shows both player clocks in the ready state', (tester) async {
    await tester.pumpWidget(const ChessClockApp());

    expect(find.text('Chess Clock'), findsOneWidget);
    expect(find.text('WHITE'), findsOneWidget);
    expect(find.text('BLACK'), findsOneWidget);
    expect(find.text('05:00'), findsNWidgets(2));
    expect(find.byIcon(Icons.swap_vert), findsOneWidget);
    expect(find.byIcon(Icons.restart_alt), findsOneWidget);
  });
}
