import 'package:food_app/database/cart_item.dart';

class CartManager {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  void addItem(CartItem item) {
    final existingIndex = _items.indexWhere((i) => i.product_id == item.product_id);
    
    if (existingIndex >= 0) {
      // Item already in cart, increase quantity
      _items[existingIndex].quantity += item.quantity;
    } else {
      // New item, add to cart
      _items.add(item);
    }
  }

  void removeItem(int product_id) {
    _items.removeWhere((item) => item.product_id == product_id);
  }

  void updateQuantity(int product_id, int quantity) {
    final itemIndex = _items.indexWhere((i) => i.product_id == product_id);
    if (itemIndex >= 0) {
      if (quantity <= 0) {
        _items.removeAt(itemIndex);
      } else {
        _items[itemIndex].quantity = quantity;
      }
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
  }
}
