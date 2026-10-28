import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:b3_verification/main.dart';

void main() {
  testWidgets('renders the tip calculator screen', (tester) async {
    await tester.pumpWidget(const B3VerificationApp());

    expect(find.text('Tip Calculator'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
  });
}
