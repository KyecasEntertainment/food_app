import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:food_app/custom_top_bar.dart';
import 'package:food_app/database/address.dart';
import 'package:food_app/database/saved_address.dart';
import 'package:food_app/delivery_address.dart';

void main() {
  const complete = Address(
    unitHouseLotNumber: 'Unit 4',
    street: 'Rizal Street',
    subdivisionVillage: 'Green Village',
    barangay: 'Poblacion',
    municipality: 'Calamba',
    province: 'Laguna',
    latitude: 14.2,
    longitude: 121.1,
  );

  tearDown(DeliveryAddress.clear);

  test('saved address keeps required details and selected state', () {
    final address = SavedAddress.fromJson({
      'id': 'address-1',
      'label_kind': 'Home',
      'name': 'Home',
      'is_selected': true,
      ...complete.toJson(),
    });
    expect(address.needsReview, isFalse);
    expect(address.address.street, 'Rizal Street');
    expect(address.address.province, 'Laguna');
    DeliveryAddress.replaceSaved([address]);
    expect(DeliveryAddress.selected?.id, 'address-1');
    expect(DeliveryAddress.current.value, contains('Rizal Street'));
  });

  test('legacy address needs review and empty selection stays optional', () {
    final legacy = SavedAddress(
      id: 'old-address',
      kind: 'Custom',
      name: 'Address 1',
      address: const Address(
        formattedAddress: 'Old saved location',
        unitHouseLotNumber: '',
        subdivisionVillage: '',
        barangay: '',
        municipality: '',
        latitude: 14.2,
        longitude: 121.1,
      ),
    );
    expect(legacy.needsReview, isTrue);
    DeliveryAddress.replaceSaved([legacy]);
    expect(DeliveryAddress.selected, isNull);
    expect(DeliveryAddress.current.value, isEmpty);
  });

  testWidgets('top bar opens the empty address list', (tester) async {
    DeliveryAddress.clear();
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(appBar: CustomAppBar(showAddress: true)),
      ),
    );
    await tester.tap(find.text('+ Set your address'));
    await tester.pumpAndSettle();
    expect(find.text('Your addresses'), findsOneWidget);
    expect(find.text('+ Set your address'), findsNWidgets(2));
    await tester.tap(find.text('+ Set your address').last);
    await tester.pumpAndSettle();
    expect(find.text('Add address'), findsOneWidget);
    expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    expect(find.text('Unit/Floor/Building'), findsOneWidget);
    final sheetTopBefore = tester.getTopLeft(find.text('Add address')).dy;
    await tester.drag(find.text('Add address'), const Offset(0, -240));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Add address')).dy, lessThan(sheetTopBefore));
  });

  testWidgets('top bar lists saved addresses and an add action', (
    tester,
  ) async {
    DeliveryAddress.replaceSaved([
      const SavedAddress(
        id: 'home',
        kind: 'Home',
        name: 'Home',
        address: complete,
        isSelected: true,
      ),
      const SavedAddress(
        id: 'work',
        kind: 'Work',
        name: 'Work',
        address: complete,
      ),
    ]);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(appBar: CustomAppBar(showAddress: true)),
      ),
    );
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
    expect(find.text('+ Add Address'), findsOneWidget);
  });
}
