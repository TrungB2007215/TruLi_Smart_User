class Catelogies {
  final int catelogyId;
  final String name;

  Catelogies({
    required this.catelogyId,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'catelogy_id': catelogyId,
      'name': name,
    };
  }

  factory Catelogies.fromMap(Map<String, dynamic> map) {
    return Catelogies(
      catelogyId: map['catelogy_id'] ?? '',
      name: map['name'] ?? '',
    );
  }
}
