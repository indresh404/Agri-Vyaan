import 'package:flutter_test/flutter_test.dart';
import 'package:app/main.dart';

void main() {
  testWidgets('AgriSwarm onboarding screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that onboarding header is present.
    expect(find.text('Welcome to AgriSwarm'), findsOneWidget);
    expect(find.text('Let\'s Understand Your Farm'), findsOneWidget);
  });
}
