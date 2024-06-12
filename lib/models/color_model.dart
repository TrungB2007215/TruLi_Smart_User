class ColorModel {
  final String colorId;
  final String name;

  ColorModel({
    required this.colorId,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'color_id': colorId,
      'name': name,
    };
  }

  factory ColorModel.fromMap(Map<String, dynamic> map) {
    return ColorModel(
      colorId: map['color_id'],
      name: map['name'],
    );
  }
}
