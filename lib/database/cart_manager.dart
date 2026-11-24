import 'package:flutter/foundation.dart';
import 'package:food_app/database/cart_item.dart';

class CartManager extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get distinctProductCount =>
      _items.map((item) => item.product_id).toSet().length;

  void addItem(CartItem item) {
    final existingIndex = _items.indexWhere(
      (i) => i.product_id == item.product_id,
    );

    if (existingIndex >= 0) {
      // Item already in cart, increase quantity
      _items[existingIndex].quantity += item.quantity;
    } else {
      // New item, add to cart
      _items.add(item);
    }
    notifyListeners();
  }

  void removeItem(int product_id) {
    _items.removeWhere((item) => item.product_id == product_id);
    notifyListeners();
  }

  void updateQuantity(int product_id, int quantity) {
    final itemIndex = _items.indexWhere((i) => i.product_id == product_id);
    if (itemIndex >= 0) {
      if (quantity <= 0) {
        _items.removeAt(itemIndex);
      } else {
        _items[itemIndex].quantity = quantity;
      }
      notifyListeners();
    }
  }

  double get totalPrice {
    return _items.fold(0, (sum, item) => sum + item.subtotal);
  }

  int get itemCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
