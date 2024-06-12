import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetail {
  final String orderId;
  final String productName;
  final String shopOwnerEmail;
  final double price;
  final int quantity;

  OrderDetail({
    required this.orderId,
    required this.productName,
    required this.shopOwnerEmail,
    required this.price,
    required this.quantity,
  });

  factory OrderDetail.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var data = snapshot.data()!;
    return OrderDetail(
      orderId: data['orderId'],
      productName: data['productName'],
      shopOwnerEmail: data['shopOwnerEmail'],
      price: data['price'],
      quantity: data['quantity'],
    );
  }
}
