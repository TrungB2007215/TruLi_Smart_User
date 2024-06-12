import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/order_service.dart';
import '../../../services/user_service.dart';
import '../../models/order_details_model.dart';
import '../../models/orders_model.dart';

class ConfirmingScreen extends StatefulWidget {
  final String loggedInUserEmail;

  ConfirmingScreen({required this.loggedInUserEmail});

  @override
  _ConfirmingScreenState createState() => _ConfirmingScreenState();
}

class _ConfirmingScreenState extends State<ConfirmingScreen> {
  late Future<List<Order>> _confirmingOrdersFuture;

  @override
  void initState() {
    super.initState();
    _confirmingOrdersFuture = OrderService()
        .getOrdersByStatusAndUserEmail('Confirming', widget.loggedInUserEmail);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đơn hàng đang chờ xác nhận'),
      ),
      body: FutureBuilder<List<Order>>(
        future: _confirmingOrdersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Đã xảy ra lỗi: ${snapshot.error}'),
            );
          } else {
            List<Order>? confirmingOrders = snapshot.data;

            if (confirmingOrders != null && confirmingOrders.isNotEmpty) {
              return ListView.builder(
                itemCount: confirmingOrders.length,
                itemBuilder: (context, index) {
                  Order order = confirmingOrders[index];

                  return FutureBuilder<List<OrderDetail>>(
                    future: OrderService().getOrderDetailsByOrderId(order.id),
                    builder: (context, orderDetailSnapshot) {
                      if (orderDetailSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (orderDetailSnapshot.hasError) {
                        return Center(
                          child: Text(
                              'Đã xảy ra lỗi: ${orderDetailSnapshot.error}'),
                        );
                      } else {
                        List<OrderDetail>? orderDetails =
                            orderDetailSnapshot.data;

                        if (orderDetails != null && orderDetails.isNotEmpty) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FutureBuilder<String?>(
                                future: UserService().getUserInfo(
                                    orderDetails.first.shopOwnerEmail),
                                builder: (context, userInfoSnapshot) {
                                  if (userInfoSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (userInfoSnapshot.hasError) {
                                    return Center(
                                      child: Text(
                                          'Đã xảy ra lỗi: ${userInfoSnapshot.error}'),
                                    );
                                  } else {
                                    String? userName = userInfoSnapshot.data;

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 8.0),
                                      child: Text(
                                        '${userName ?? 'Người dùng'}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                              ListTile(
                                title: Text(
                                    'Ngày đặt hàng: ${DateFormat('dd/MM/yyyy').format(order.orderDate)}'),
                                subtitle: Text(
                                    'Tổng tiền: ${NumberFormat.currency(decimalDigits: 0, symbol: '').format(order.totalValue)}đ'),
                              ),
                              SizedBox(height: 8),
                              Divider(),
                              Column(
                                children: orderDetails.map((detail) {
                                  return ListTile(
                                    title: Text(detail.productName),
                                    subtitle: Text(
                                        'Số lượng: ${detail.quantity} - Giá: ${NumberFormat.currency(decimalDigits: 0, symbol: '').format(detail.price)}đ'),
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  confirmOrder(order);
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.blue,
                                ),
                                child: Text('Hủy đơn hàng',
                                    style: TextStyle(color: Colors.black)),
                              ),
                              SizedBox(height: 16),
                            ],
                          );
                        } else {
                          return Center(
                            child: Text('Không có chi tiết đơn hàng'),
                          );
                        }
                      }
                    },
                  );
                },
              );
            } else {
              return Center(
                child: Text('Không có đơn hàng đang chờ xác nhận'),
              );
            }
          }
        },
      ),
    );
  }

  void confirmOrder(Order order) async {
    try {
      List<OrderDetail>? orderDetails =
          await OrderService().getOrderDetailsByOrderId(order.id);

      if (orderDetails != null && orderDetails.isNotEmpty) {
        for (var detail in orderDetails) {
          String productName = detail.productName;
          String shopOwnerEmail = detail.shopOwnerEmail;
          int quantity = detail.quantity;

          await OrderService().updateOrderStatus(order.id, 'Canceled');
          print('Confirmed order: ${order.id}');
        }
      }
    } catch (e) {
      print('Error confirming order: $e');
    }
  }
}
