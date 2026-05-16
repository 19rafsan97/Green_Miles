import 'package:flutter_test/flutter_test.dart';
import 'package:green_miles_app/main.dart';

void main() {
  testWidgets('shows Supabase config message when keys are missing', (WidgetTester tester) async {
    await tester.pumpWidget(const SupabaseConfigMissingApp());
    expect(find.textContaining('Supabase is not configured'), findsOneWidget);
  });
}
