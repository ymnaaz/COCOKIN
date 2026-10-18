import 'package:flutter_test/flutter_test.dart';
import 'package:cocokin/main.dart';

void main() {
  testWidgets('Cocokin app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CocokinApp());
    expect(find.text('cocokin.'), findsOneWidget);
  });
}
