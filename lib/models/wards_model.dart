class WardsModel {
  final String wardId;
  final String districtId;
  final String name;

  WardsModel({
    required this.wardId,
    required this.districtId,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'ward_id': wardId,
      'district_id': districtId,
      'name': name,
    };
  }

  factory WardsModel.fromMap(Map<String, dynamic> map) {
    return WardsModel(
      wardId: map['ward_id'],
      districtId: map['district_id'],
      name: map['name'],
    );
  }
}
