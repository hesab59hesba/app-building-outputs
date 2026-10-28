import 'package:flutter_test/flutter_test.dart';

import 'package:carspot/main.dart';
import 'package:carspot/spot_store.dart';

void main() {
  testWidgets('CarSpot renders the parking spot saver', (tester) async {
    await tester.pumpWidget(CarSpotApp(store: SpotStore()));

    expect(find.text('CarSpot'), findsOneWidget);
    expect(find.text('Where did you park?'), findsOneWidget);
    expect(find.text('Save my parking spot'), findsOneWidget);
  });
}
