import 'package:flutter/foundation.dart';
import 'package:food_app/database/cart_item.dart';
import 'package:food_app/database/local_database.dart';

class CartManager extends ChangeNotifier {
  CartManager({this.accountId, FoodRepository? repository})
    : _repository = repository ?? activeRepository;

  final String? accountId;
  final FoodRepository _repository;
  final List<CartItem> _items = [];
  Future<void> _pendingSave = Future.value();
  bool _edited = false;

  Future<void> load() async {
    if (accountId == null) return;
    final saved = await _repository.getCart(accountId!);
    if (_edited) return;
    _items.addAll(saved);
    notifyListeners();
  }

  void _save() {
    _edited = true;
    if (accountId == null) return;
    final snapshot = _items
        .map((item) => CartItem.fromJson(item.toJson()))
        .toList();
    _pendingSave = _pendingSave.then(
      (_) => _repository.saveCart(accountId!, snapshot),
    );
  }

  List<CartItem> get items => _items;

  int get distinctProductCount =>
      _items.map((item) => item.itemId).toSet().length;

  void addItem(CartItem item) {
    final existingIndex = _items.indexWhere((i) => i.itemId == item.itemId);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += item.quantity;
    } else {
      _items.add(item);
    }
    _save();
    notifyListeners();
  }

  void removeItem(int itemId) {
    _items.removeWhere((item) => item.itemId == itemId);
    _save();
    notifyListeners();
  }

  void updateQuantity(int itemId, int quantity) {
    final itemIndex = _items.indexWhere((i) => i.itemId == itemId);
    if (itemIndex >= 0) {
      if (quantity <= 0) {
        _items.removeAt(itemIndex);
      } else {
        _items[itemIndex].quantity = quantity;
      }
      _save();
      notifyListeners();
    }
  }

  double get totalPrice => _items.fold(0, (sum, item) => sum + item.subtotal);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  void clearCart() {
    _items.clear();
    _save();
    notifyListeners();
  }

  Future<void> get saved => _pendingSave;
}
