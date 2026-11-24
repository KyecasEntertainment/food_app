import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_app/database/address.dart';
import 'package:food_app/database/cart_item.dart';
import 'package:food_app/database/cart_manager.dart';
import 'package:food_app/database/demo_auth.dart';
import 'package:food_app/database/local_database.dart';
import 'package:food_app/database/order.dart';
import 'package:food_app/database/product_list.dart';
import 'package:food_app/database/user_accounts.dart';

const deliveryAddress = Address(
  unitHouseLotNumber: 'Lot 12',
  subdivisionVillage: 'Pine Village',
  barangay: 'Baybay',
  municipality: 'Los Baños',
  latitude: 14.166,
  longitude: 121.244,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('address and account use Supabase-ready field names', () {
    final address = Address.fromJson(deliveryAddress.toJson());
    expect(address.displayText, 'Lot 12, Pine Village, Baybay, Los Baños');
    expect(address.latitude, 14.166);
    expect(address.isComplete, isTrue);

    final account = accounts.first.copyWith(address: address);
    final decoded = UserAccounts.fromJson(account.toJson());
    expect(decoded.id, account.id);
    expect(decoded.firstName, 'John');
    expect(decoded.lastName, 'Doe');
    expect(decoded.address.longitude, 121.244);
    expect(account.toJson(), isNot(contains('password')));
  });

  test('food item keeps its ID, photo, name and price across JSON', () {
    final item = FoodItem.fromJson(products.first.toJson());
    expect(item.id, 1);
    expect(item.photo, products.first.photo);
    expect(item.name, 'Classic Burger');
    expect(item.price, 149);
  });

  test('order snapshots item IDs, quantities, address and prices', () {
    final order = FoodOrder.fromCart(
      cartItems: [
        CartItem(
          itemId: 2,
          name: 'Pizza',
          photo: '',
          unitPrice: 200,
          quantity: 2,
        ),
        CartItem(itemId: 5, name: 'Burger', photo: '', unitPrice: 150),
      ],
      deliveryAddress: deliveryAddress,
      shippingPrice: 45,
      tipPrice: 10,
      accountId: accounts.first.id,
    );
    final decoded = FoodOrder.fromJson(order.toJson());
    expect(
      decoded.id,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
    expect(decoded.items.map((item) => item.itemId), [2, 5]);
    expect(decoded.items.map((item) => item.quantity), [2, 1]);
    expect(decoded.shippingPrice, 45);
    expect(decoded.totalPrice, 605);
    expect(decoded.deliveryAddress.barangay, 'Baybay');
  });

  test(
    'local storage persists profiles, carts and orders by account',
    () async {
      final db = LocalDatabase.instance;
      final account = accounts.first.copyWith(address: deliveryAddress);
      await db.saveAccount(account);
      expect((await db.getAccount(account.id))!.address.latitude, 14.166);

      final cart = CartManager(accountId: account.id, repository: db);
      cart.addItem(
        CartItem(
          itemId: 1,
          name: 'Burger',
          photo: 'burger.jpg',
          unitPrice: 100,
          quantity: 2,
        ),
      );
      await cart.saved;
      final restored = CartManager(accountId: account.id, repository: db);
      await restored.load();
      expect(restored.itemCount, 2);
      expect(await db.getCart(accounts[1].id), isEmpty);

      final order = FoodOrder.fromCart(
        cartItems: restored.items,
        deliveryAddress: deliveryAddress,
        shippingPrice: 30,
        accountId: account.id,
      );
      await db.saveOrder(order);
      expect((await db.getOrders(account.id)).single.totalPrice, 230);
      expect(await db.getOrders(accounts[1].id), isEmpty);

      cart.dispose();
      restored.dispose();
    },
  );

  test(
    'demo authentication loads the saved profile after an email edit',
    () async {
      final updated = accounts.first.copyWith(email: 'john.new@example.com');
      await LocalDatabase.instance.saveAccount(updated);
      expect(
        await DemoAuth.signIn('john.new@example.com', '12345678'),
        isA<UserAccounts>().having((user) => user.id, 'id', updated.id),
      );
      expect(
        await DemoAuth.signIn('john.new@example.com', 'wrongpass'),
        isNull,
      );
    },
  );
}
