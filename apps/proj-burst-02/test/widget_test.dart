import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flashcards/main.dart';

void main() {
  testWidgets('app boots and shows the first card', (tester) async {
    await tester.pumpWidget(const FlashcardsApp());

    expect(find.text('Flashcards'), findsOneWidget);
    expect(find.text('Question'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('card flips and tally advances through the deck',
      (tester) async {
    await tester.pumpWidget(const FlashcardsApp());

    expect(find.text('What does CPU stand for?'), findsOneWidget);

    // Flip the card to reveal the answer.
    await tester.tap(find.text('What does CPU stand for?'));
    await tester.pumpAndSettle();

    expect(find.text('Answer'), findsOneWidget);
    expect(find.text('Central Processing Unit'), findsOneWidget);
    expect(find.text('Correct'), findsOneWidget);
    expect(find.text('Wrong'), findsOneWidget);

    // Mark the card correct; the deck advances and tally reflects it.
    await tester.tap(find.text('Correct'));
    await tester.pumpAndSettle();

    expect(find.text('Which planet is closest to the Sun?'), findsOneWidget);
    expect(find.text('Card 2 / 6'), findsOneWidget);
  });

  testWidgets('reaching the end shows per-card tallies and restart',
      (tester) async {
    await tester.pumpWidget(const FlashcardsApp());

    const questions = [
      'What does CPU stand for?',
      'Which planet is closest to the Sun?',
      'What is the capital of Portugal?',
      'In Flutter, which widget centers its child?',
      'How many sides does a hexagon have?',
      'What does HTTP status 404 mean?',
    ];

    for (final question in questions) {
      await tester.tap(find.text(question), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Correct'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Deck complete!'), findsOneWidget);

    // Restart from the summary screen.
    await tester.tap(find.text('Study again'));
    await tester.pumpAndSettle();

    expect(find.text('What does CPU stand for?'), findsOneWidget);
  });
}
