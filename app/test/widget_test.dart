import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/main.dart';

void main() {
  testWidgets('Agrivyaan app onboarding smoke test', (WidgetTester tester) async {
    // Initialize SharedPreferences with empty values for test environment
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const AgrivyaanApp());
    await tester.pumpAndSettle();

    // Verify that onboarding language selection is present on initial launch
    expect(find.text('Choose Your Language'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
