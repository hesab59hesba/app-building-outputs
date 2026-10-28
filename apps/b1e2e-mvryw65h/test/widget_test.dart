import "package:b1_verification/main.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  testWidgets("counter increments when the button is tapped", (tester) async {
    await tester.pumpWidget(const B1VerificationApp());

    expect(find.text("0"), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text("1"), findsOneWidget);
  });
}
