class Brand {
  final String brandId;
  final String name;
  final String image;

  Brand({
    required this.brandId,
    required this.name,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'brand_id': brandId,
      'name': name,
      'image': image,
    };
  }

  factory Brand.fromMap(Map<String, dynamic> map) {
    return Brand(
      brandId: map['brand_id'],
      name: map['name'],
      image: map['image'],
    );
  }
}
