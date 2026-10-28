import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vault_probe/main.dart';

void main() {
  testWidgets('dice roller shows result and roll button works', (tester) async {
    await tester.pumpWidget(const VaultProbeApp());
    await tester.pumpAndSettle();

    expect(find.text('You rolled a 1'), findsOneWidget);
    expect(find.byIcon(Icons.casino), findsOneWidget);

    await tester.tap(find.text('Roll'));
    await tester.pumpAndSettle();

    final digits = List.generate(6, (i) => 'You rolled a ${i + 1}');
    final visible = digits.where((d) => find.text(d).evaluate().isNotEmpty);
    expect(visible, isNotEmpty);
  });
}
