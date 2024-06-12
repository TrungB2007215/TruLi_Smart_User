class ImageModel {
  final String imageId;
  final String productId; // Assuming it's related to a product, adjust as needed
  final String imagePath;

  ImageModel({
    required this.imageId,
    required this.productId,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'image_id': imageId,
      'product_id': productId,
      'image_path': imagePath,
    };
  }

  factory ImageModel.fromMap(Map<String, dynamic> map) {
    return ImageModel(
      imageId: map['image_id'],
      productId: map['product_id'],
      imagePath: map['image_path'],
    );
  }
}
