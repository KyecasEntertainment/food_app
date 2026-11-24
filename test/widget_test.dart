import 'package:flutter_test/flutter_test.dart';
import 'package:food_app/main.dart';

void main() {
  testWidgets('app opens on the login screen', (tester) async {
    await tester.pumpWidget(const Main());
    expect(find.text('WELCOME'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
