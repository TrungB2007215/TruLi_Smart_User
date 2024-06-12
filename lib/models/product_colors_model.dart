class ProductColorsModel {
  final String colorId;
  final String productId;

  ProductColorsModel({
    required this.colorId,
    required this.productId,
  });

  Map<String, dynamic> toMap() {
    return {
      'color_id': colorId,
      'product_id': productId,
    };
  }

  factory ProductColorsModel.fromMap(Map<String, dynamic> map) {
    return ProductColorsModel(
      colorId: map['color_id'],
      productId: map['product_id'],
    );
  }
}
