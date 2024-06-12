class Product {
  final String brandName;
  final String name;
  final double sellingPrice;
  final String describe;
  final String catelogyName;
  final List<ProductImage> color;
  final List<ProductImage> images;

  Product({
    required this.brandName,
    required this.name,
    required this.sellingPrice,
    required this.describe,
    required this.catelogyName,

    required this.color,
    required this.images,
  });
}

class ProductImage {
  final String imagePath;
  final String color;

  ProductImage({
    required this.imagePath,
    required this.color,
  });
}
