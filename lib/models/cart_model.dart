class Cart {
  final String cartId;
  final String userId;
  final String productId;
  final double price;
  final String quantity;

  Cart({
    required this.cartId,
    required this.userId,
    required this.productId,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'cart_id': cartId,
      'user_id': userId,
      'product_id': productId,
      'price': price,
      'quantity': quantity,
    };
  }

  factory Cart.fromMap(Map<String, dynamic> map) {
    return Cart(
      cartId: map['cart_id'],
      userId: map['user_id'],
      productId: map['product_id'],
      price: map['price'],
      quantity: map['quantity'],
    );
  }
}
