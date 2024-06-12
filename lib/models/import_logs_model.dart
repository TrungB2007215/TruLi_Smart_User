class ImportLogsModel {
  final String importId;
  final String category;
  final String brand;
  final String productName;
  final String userEmail;
  final DateTime importDate;
  final double importPrice;
  final int quantity;


  ImportLogsModel({
    required this.category,
    required this.brand,
    required this.importId,
    required this.productName,
    required this.userEmail,
    required this.importDate,
    required this.importPrice,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'brand': brand,
      'import_id': importId,
      'product_name': productName,
      'userName': userEmail,
      'import_date': importDate.toIso8601String(),
      'cost': importPrice,
      'quantity': quantity,

    };
  }

  factory ImportLogsModel.fromMap(Map<String, dynamic> map) {
    return ImportLogsModel(

      importId: map['import_id'],
      productName: map['product_name'],
      userEmail: map['userEmail'],
      importDate: DateTime.parse(map['import_date']),
      importPrice: map['importPrice'],
      quantity: map['quantity'],
      category: map['category'],
      brand: map['brand'],
    );
  }
}
