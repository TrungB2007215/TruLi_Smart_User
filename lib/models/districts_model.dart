class DistrictsModel {
  final String districtId;
  final String provinceId;
  final String name;

  DistrictsModel({
    required this.districtId,
    required this.provinceId,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'district_id': districtId,
      'province_id': provinceId,
      'name': name,
    };
  }

  factory DistrictsModel.fromMap(Map<String, dynamic> map) {
    return DistrictsModel(
      districtId: map['district_id'],
      provinceId: map['province_id'],
      name: map['name'],
    );
  }
}
