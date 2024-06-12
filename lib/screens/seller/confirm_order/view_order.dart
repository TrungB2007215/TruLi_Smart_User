import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/order_service.dart';
import '../../../services/user_service.dart';
import '../../../models/order_details_model.dart';
import '../../../models/orders_model.dart';

class ViewOrder extends StatefulWidget {
  final String loggedInUserEmail;

  ViewOrder({required this.loggedInUserEmail});

  @override
  _ViewOrderScreenState createState() => _ViewOrderScreenState();
}

class _ViewOrderScreenState extends State<ViewOrder> {
  late Future<List<Order>> _confirmingOrdersFuture;

  @override
  void initState() {
    super.initState();
    _confirmingOrdersFuture = OrderService().getOrdersByStatus('Confirming');
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
                      if (orderDetailSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (orderDetailSnapshot.hasError) {
                        return Center(
                          child: Text('Đã xảy ra lỗi: ${orderDetailSnapshot.error}'),
                        );
                      } else {
                        List<OrderDetail>? orderDetails = orderDetailSnapshot.data;

                        if (orderDetails != null && orderDetails.isNotEmpty) {
                          List<OrderDetail> filteredDetails = orderDetails.where((detail) => detail.shopOwnerEmail == widget.loggedInUserEmail).toList();

                          if (filteredDetails.isNotEmpty) {
                            return FutureBuilder<String?>(
                              future: UserService().getUserInfo(filteredDetails.first.shopOwnerEmail),
                              builder: (context, userInfoSnapshot) {
                                if (userInfoSnapshot.connectionState == ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (userInfoSnapshot.hasError) {
                                  return Center(
                                    child: Text('Đã xảy ra lỗi: ${userInfoSnapshot.error}'),
                                  );
                                } else {
                                  String? userName = userInfoSnapshot.data;

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                        child: Text(
                                          '${userName ?? 'Người dùng'}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        title: Text('Ngày đặt hàng: ${DateFormat('dd/MM/yyyy').format(order.orderDate)}'),
                                        subtitle: Text('Tổng tiền: ${NumberFormat.currency(decimalDigits: 0, symbol: '').format(order.totalValue)}đ'),
                                      ),
                                      SizedBox(height: 8),
                                      Divider(),
                                      Column(
                                        children: filteredDetails.map((detail) {
                                          return ListTile(
                                            title: Text(detail.productName),
                                            subtitle: Text('Số lượng: ${detail.quantity} - Giá: ${NumberFormat.currency(decimalDigits: 0, symbol: '').format(detail.price)}đ'),
                                          );
                                        }).toList(),
                                      ),
                                      SizedBox(height: 16),

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              confirmOrder(order);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.blue,
                                            ),
                                            child: Text('Xác nhận đơn hàng', style: TextStyle(color: Colors.black)),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              rejectOrder(order);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.red,
                                            ),
                                            child: Text('Từ chối đơn hàng', style: TextStyle(color: Colors.black)),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                    ],
                                  );
                                }
                              },
                            );
                          } else {
                            return SizedBox.shrink(); // Không hiển thị gì nếu không có chi tiết đơn hàng cho user
                          }
                        } else {
                          return SizedBox.shrink(); // Không hiển thị gì nếu không có chi tiết đơn hàng
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
  void rejectOrder(Order order) async {
    try {
      await OrderService().updateOrderStatus(order.id, 'Rejected');
      print('Đã từ chối đơn hàng: ${order.id}');
    } catch (e) {
      print('Lỗi từ chối đơn hàng: $e');
    }
  }
  void confirmOrder(Order order) async {
    try {
      await OrderService().updateOrderStatus(order.id, 'Confirmed');
      print('Đã xác nhận đơn hàng: ${order.id}');
    } catch (e) {
      print('Lỗi xác nhận đơn hàng: $e');
    }
  }
}
