import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_details_model.dart';
import '../models/orders_model.dart' as my_orders;

class OrderService {

  final CollectionReference ordersCollection = FirebaseFirestore.instance.collection('orders');
  final CollectionReference orderDetailsCollection = FirebaseFirestore.instance.collection('order_details');

  Future<void> placeOrder({
    required my_orders.Order order,
    required List<OrderDetail> orderDetails,
  }) async {
    try {
      DocumentReference orderRef = await ordersCollection.add({
        'userEmail': order.userEmail,
        'addressId': order.addressId,
        'totalValue': order.totalValue,
        'orderDate': order.orderDate,
        'orderStatus': order.orderStatus,
      });

      for (var detail in orderDetails) {
        await orderDetailsCollection.add({
          'orderId': orderRef.id,
          'productName': detail.productName,
          'shopOwnerEmail': detail.shopOwnerEmail,
          'price': detail.price,
          'quantity': detail.quantity,
        });
      }
    } catch (e) {
      print('Error placing order: $e');
      throw e;
    }
  }

  Future<List<my_orders.Order>> getOrdersByStatus(String status) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('orderStatus', isEqualTo: status)
          .get();

      List<my_orders.Order> orders = querySnapshot.docs.map((doc) => my_orders.Order.fromSnapshot(doc)).toList();
      return orders;
    } catch (e) {
      print('Error getting orders by status: $e');
      throw e;
    }
  }

  Future<List<my_orders.Order>> getOrdersByStatusAndUserEmail(String status, String loggedInUserEmail) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userEmail', isEqualTo: loggedInUserEmail)
          .where('orderStatus', isEqualTo: status)
          .get();

      List<my_orders.Order> orders = querySnapshot.docs.map((doc) => my_orders.Order.fromSnapshot(doc)).toList();
      return orders;
    } catch (e) {
      print('Error getting orders by status: $e');
      throw e;
    }
  }

  Future<List<OrderDetail>> getOrderDetailsByOrderId(String orderId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('order_details')
          .where('orderId', isEqualTo: orderId)
          .get();

      List<OrderDetail> orderDetails =
      querySnapshot.docs.map((doc) => OrderDetail.fromSnapshot(doc)).toList();
      return orderDetails;
    } catch (e) {
      print('Error getting order details by order ID: $e');
      throw e;
    }
  }

  Future<int> getOrderCountByStatus(String status, String loggedInUserEmail) async {
    try {
      print(status);
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userEmail', isEqualTo: loggedInUserEmail)
          .where('orderStatus', isEqualTo: status)
          .get();
      print(querySnapshot.size);
      return querySnapshot.size;
    } catch (e) {
      print('Error getting order count by status: $e');
      return 0;
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {

    await FirebaseFirestore.instance.collection('orders').doc(orderId.toString()).update({
      'orderStatus': newStatus,
    });
  }

  Future<List<my_orders.Order>> getOrdersByShop(String status, String loggedInUserEmail) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('orderStatus', isEqualTo: status)
          .where('userEmail', isEqualTo: loggedInUserEmail)
          .get();

      List<my_orders.Order> orders = querySnapshot.docs.map((doc) => my_orders.Order.fromSnapshot(doc)).toList();
      return orders;
    } catch (e) {
      print('Error getting orders by status: $e');
      throw e;
    }
  }



}
