import 'package:flutter_test/flutter_test.dart';
import 'package:food_app/database/cart_item.dart';
import 'package:food_app/database/cart_manager.dart';

void main() {
  test('cart badge counts products, not quantities', () {
    final cart = CartManager();
    addTearDown(cart.dispose);
    final badgeCounts = <int>[];
    cart.addListener(() => badgeCounts.add(cart.distinctProductCount));

    cart.addItem(
      CartItem(itemId: 1, name: 'Cheese Burger', photo: '', unitPrice: 100),
    );
    cart.addItem(
      CartItem(
        itemId: 2,
        name: 'Pizza',
        photo: '',
        unitPrice: 200,
        quantity: 2,
      ),
    );
    expect(cart.distinctProductCount, 2);
    expect(cart.itemCount, 3);

    cart.addItem(CartItem(itemId: 2, name: 'Pizza', photo: '', unitPrice: 200));
    expect(cart.distinctProductCount, 2);
    expect(cart.itemCount, 4);

    cart.updateQuantity(1, 0);
    expect(cart.distinctProductCount, 1);
    cart.clearCart();
    expect(cart.distinctProductCount, 0);
    expect(badgeCounts, [1, 2, 2, 1, 0]);
  });
}
