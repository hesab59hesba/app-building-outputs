import 'package:dice_roller/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dice roller smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DiceRollerApp());

    expect(find.text('Dice Roller'), findsOneWidget);
    expect(find.text('d20'), findsOneWidget);
    expect(find.text('No rolls yet'), findsOneWidget);

    await tester.tap(find.text('Roll d4'));
    await tester.pump();
  });
}
