import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id; // Add an id property to hold the document ID
  final String userEmail;
  final String addressId;
  final double totalValue;
  final DateTime orderDate;
  final String orderStatus;

  Order({
    required this.id,
    required this.userEmail,
    required this.addressId,
    required this.totalValue,
    required this.orderDate,
    required this.orderStatus,
  });

  // Factory method to create Order object from Firestore document snapshot
  factory Order.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var data = snapshot.data()!;
    return Order(
      id: snapshot.id,
      userEmail: data['userEmail'],
      addressId: data['addressId'],
      totalValue: data['totalValue'],
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      orderStatus: data['orderStatus'],
    );
  }
}
