class ProductModel {
  final String productId;
  final String brandId;
  final String name;
  final double purchasePrice;
  final double sellingPrice;
  final String describe;
  final String catelogyId;
  final String mainImagePath;
  final String color;

  ProductModel({
    required this.productId,
    required this.brandId,
    required this.name,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.describe,
    required this.catelogyId,
    required this.mainImagePath,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'brand_id': brandId,
      'name': name,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'describe': describe,
      'catelogy_id': catelogyId,
      'main_image_path': mainImagePath,
      'color': color,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      productId: map['product_id'],
      brandId: map['brand_id'],
      name: map['name'],
      purchasePrice: map['purchase_price'],
      sellingPrice: map['selling_price'],
      describe: map['describe'],
      catelogyId: map['catelogy_id'],
      mainImagePath: map['main_image_path'],
      color: map['color'],
    );
  }
}
