import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_app/app_navigation.dart';
import 'package:food_app/database/address.dart';
import 'package:food_app/database/cart_item.dart';
import 'package:food_app/database/local_database.dart';
import 'package:food_app/database/order.dart';
import 'package:food_app/screen/delivery_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('delivered order can be rated and opens its E-Receipt', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    const address = Address(
      formattedAddress: '123 Sample Street, Manila',
      unitHouseLotNumber: '',
      subdivisionVillage: '',
      barangay: '',
      municipality: '',
      latitude: 14.5995,
      longitude: 120.9842,
    );
    final draft = FoodOrder.fromCart(
      cartItems: [
        CartItem(
          itemId: 1,
          name: 'Classic Burger',
          photo: '',
          unitPrice: 149,
          quantity: 2,
        ),
      ],
      deliveryAddress: address,
      shippingPrice: 50,
      accountId: 'test-account',
      paymentMethod: 'COD',
    );
    final order = draft.copyWith(
      status: OrderStatus.delivered,
      deliveredAt: DateTime.now().toUtc(),
    );
    await LocalDatabase.instance.saveOrder(order);
    activeRepository = LocalDatabase.instance;
    AppNavigation.selectTab(2);

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/tracking',
        routes: {
          '/': (_) => const Scaffold(body: Text('Home')),
          '/tracking': (_) => OrderTrackingPage(order: order),
        },
      ),
    );
    expect(find.text('Enjoy your food.'), findsOneWidget);
    expect(find.text('123 Sample Street, Manila'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
    await tester.ensureVisible(find.text('Rate rider and shop'));
    await tester.tap(find.text('Rate rider and shop'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('5 stars').first);
    await tester.pump();
    await tester.tap(find.byTooltip('4 stars').last);
    await tester.pump();
    await tester.tap(find.text('Submit ratings'));
    await tester.pumpAndSettle();

    expect(find.text('E-Receipt'), findsWidgets);
    expect(find.text('2 × Classic Burger'), findsOneWidget);
    expect(find.text('₱348.00'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Done'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Done'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Track delivery'), findsNothing);
    expect(AppNavigation.selectedTab.value, 0);
    final restored = (await LocalDatabase.instance.getOrders(
      order.accountId,
    )).single;
    expect(restored.driverRating, 5);
    expect(restored.shopRating, 4);
    debugDefaultTargetPlatformOverride = null;
  });
}
