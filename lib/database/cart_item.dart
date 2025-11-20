class CartItem {
  final int product_id;
  final String product_name;
  final String product_image;
  final double product_price;
  int quantity;

  CartItem({
    required this.product_id,
    required this.product_name,
    required this.product_image,
    required this.product_price,
    this.quantity = 1,
  });

  double get subtotal => product_price * quantity;
}
