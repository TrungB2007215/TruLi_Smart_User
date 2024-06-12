class ProvincesModel {
  final String provinceId;
  final String name;

  ProvincesModel({
    required this.provinceId,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'province_id': provinceId,
      'name': name,
    };
  }

  factory ProvincesModel.fromMap(Map<String, dynamic> map) {
    return ProvincesModel(
      provinceId: map['province_id'],
      name: map['name'],
    );
  }
}
