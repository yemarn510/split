import 'package:flutter_test/flutter_test.dart';
import 'package:split_my_bill/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    try {
      await Supabase.initialize(
        url: 'https://example.supabase.co',
        anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV4YW1wbGUiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTY0NTA2MDAwMCwiZXhwIjoxOTYwNjM2MDAwfQ.placeholder',
      );
    } catch (_) {
      // Already initialized in some test runs.
    }
  });

  testWidgets('App loads with title', (WidgetTester tester) async {
    await tester.pumpWidget(const SplitMyBillApp());
    await tester.pump();
    expect(find.text("Let's Split the Bills"), findsOneWidget);
    expect(find.text('Add Person'), findsOneWidget);
  });
}
