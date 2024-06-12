class AddressesModel {
  final String addressId;
  final String provinceId;
  final String districtId;
  final String wardId;
  final String street;

  AddressesModel({
    required this.addressId,
    required this.provinceId,
    required this.districtId,
    required this.wardId,
    required this.street,
  });

  Map<String, dynamic> toMap() {
    return {
      'address_id': addressId,
      'province_id': provinceId,
      'district_id': districtId,
      'ward_id': wardId,
      'street': street,
    };
  }

  factory AddressesModel.fromMap(Map<String, dynamic> map) {
    return AddressesModel(
      addressId: map['address_id'],
      provinceId: map['province_id'],
      districtId: map['district_id'],
      wardId: map['ward_id'],
      street: map['street'],
    );
  }
}
