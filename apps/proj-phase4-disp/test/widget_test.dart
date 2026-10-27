import 'package:flutter_test/flutter_test.dart';
import 'package:dispatch_probe/main.dart';

void main() {
  testWidgets('counter increments on tap', (tester) async {
    await tester.pumpWidget(const DispatchProbeApp());

    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.text('tap anywhere to count'));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
  });
}
