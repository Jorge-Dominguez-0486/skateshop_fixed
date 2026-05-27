import 'package:flutter_test/flutter_test.dart';
import 'package:skateshop_app/main.dart';

void main() {
  testWidgets('Shows Firebase setup screen when not configured', (WidgetTester tester) async {
    await tester.pumpWidget(const SkateShopApp(firebaseReady: false));
    expect(find.text('Firebase no configurado'), findsOneWidget);
  });
}
