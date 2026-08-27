import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/main.dart';

void main() {
  testWidgets('AgriSwarm app smoke test', (WidgetTester tester) async {
    // Initialize SharedPreferences with empty values for test environment
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const AgriSwarmApp());

    // Wait for async field loading to complete
    await tester.pumpAndSettle();

    // Verify that the dashboard loads with the greeting
    expect(find.text('Hello, Farmer \u{1F44B}'), findsOneWidget);
    expect(find.text('AgriSwarm'), findsOneWidget);
  });
}
