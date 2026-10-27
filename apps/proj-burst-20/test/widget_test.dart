import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sort_tray/main.dart';

void main() {
  testWidgets('renders the reorderable list', (WidgetTester tester) async {
    await tester.pumpWidget(const SortTrayApp());

    expect(find.text('Sort Tray'), findsOneWidget);
    expect(find.byType(ReorderableListView), findsOneWidget);
    expect(find.text('Apples'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_upward), findsWidgets);
  });
}
