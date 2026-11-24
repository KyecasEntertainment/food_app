class CartItem {
  final int itemId;
  final String name;
  final String photo;
  final double unitPrice;
  int quantity;

  CartItem({
    required this.itemId,
    required this.name,
    required this.photo,
    required this.unitPrice,
    this.quantity = 1,
  });

  double get subtotal => unitPrice * quantity;

  Map<String, dynamic> toJson() => {
    'item_id': itemId,
    'quantity': quantity,
    'unit_price': unitPrice,
    'item_name': name,
    'item_photo': photo,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    itemId: json['item_id'] as int,
    name: json['item_name'] as String? ?? '',
    photo: json['item_photo'] as String? ?? '',
    unitPrice: (json['unit_price'] as num).toDouble(),
    quantity: json['quantity'] as int,
  );
}
