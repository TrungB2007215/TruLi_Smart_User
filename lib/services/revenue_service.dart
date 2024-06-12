import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/orders_model.dart' as my_orders;
import '../models/order_details_model.dart';

class RevenueService {
  Future<double> calculateRevenue(String loggedInUserEmail, DateTime startDate, DateTime endDate) async {
    double totalRevenue = 0.0;

    try {
      Timestamp startTimestamp = Timestamp.fromDate(startDate);
      Timestamp endTimestamp = Timestamp.fromDate(endDate);

      QuerySnapshot<Map<String, dynamic>> orderSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('orderStatus', whereIn: ['Reviewed', 'Delivered'])
          .where('orderDate', isGreaterThanOrEqualTo: startTimestamp)
          .where('orderDate', isLessThanOrEqualTo: endTimestamp)
          .get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> orderDoc in orderSnapshot.docs) {
        my_orders.Order order = my_orders.Order.fromSnapshot(orderDoc);

        QuerySnapshot<Map<String, dynamic>> detailSnapshot = await FirebaseFirestore.instance
            .collection('order_details')
            .where('orderId', isEqualTo: order.id)
            .get();

        for (QueryDocumentSnapshot<Map<String, dynamic>> detailDoc in detailSnapshot.docs) {
          OrderDetail detail = OrderDetail.fromSnapshot(detailDoc);

          QuerySnapshot<Map<String, dynamic>> importLogSnapshot = await FirebaseFirestore.instance
              .collection('importLog')
              .where('productName', isEqualTo: detail.productName)
              .where('userEmail', isEqualTo: loggedInUserEmail)
              .limit(1)
              .get();

          if (importLogSnapshot.docs.isNotEmpty) {
            double importPrice = importLogSnapshot.docs[0]['importPrice'];

            totalRevenue += (detail.price - importPrice) * detail.quantity;
          }
        }
      }
    } catch (e) {
      print('Error calculating revenue: $e');
    }

    return totalRevenue;
  }
}
