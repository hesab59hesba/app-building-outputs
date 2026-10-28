import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:simple_notes/main.dart';

void main() {
  testWidgets('renders the notes home screen with an empty state', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SimpleNotesApp());
    await tester.pumpAndSettle();

    expect(find.text('Notes'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('No notes yet'), findsOneWidget);
  });
}
