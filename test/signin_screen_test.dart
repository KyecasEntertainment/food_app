import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_app/screen/signin_screen.dart';

void main() {
  testWidgets('account creation collects five fields and confirms password', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SigninScreen()));
    final createButton = find.widgetWithText(ElevatedButton, 'Create account');

    final fields = <String, String>{
      'First name': 'Ana',
      'Last name': 'Reyes',
      'Email': 'ana@example.com',
      'Password': 'strongpass123',
      'Confirm password': 'different',
    };
    for (final entry in fields.entries) {
      final field = find.widgetWithText(TextFormField, entry.key);
      await tester.scrollUntilVisible(
        field,
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(field, entry.value);
    }
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      createButton,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(createButton);
    await tester.pump();
    expect(find.text('Passwords do not match'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.widgetWithText(TextFormField, 'Confirm password'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirm password'),
      'strongpass123',
    );
    await tester.scrollUntilVisible(
      createButton,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(createButton);
    await tester.pump();
    expect(
      find.textContaining('Configure the local Supabase URL'),
      findsOneWidget,
    );
  });
}
