import 'package:flutter_test/flutter_test.dart';
import 'package:food_app/main.dart';

void main() {
  testWidgets('app explains missing local backend configuration', (tester) async {
    await tester.pumpWidget(const Main());
    expect(find.textContaining('Local Supabase is not configured'), findsOneWidget);
  });
}
