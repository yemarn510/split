import 'package:flutter_test/flutter_test.dart';
import 'package:split_my_bill/main.dart';

void main() {
  testWidgets('App loads with title', (WidgetTester tester) async {
    await tester.pumpWidget(const SplitMyBillApp());
    await tester.pump();
    expect(find.text("Let's Split the Bills"), findsOneWidget);
    expect(find.text('Add Person'), findsOneWidget);
  });
}
