import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/order_service.dart';
import '../../../services/user_service.dart';
import '../../../services/review_service.dart';
import '../../../models/order_details_model.dart';
import '../../../models/orders_model.dart';
import '../../../models/reviews_model.dart';

class DeliveredScreen extends StatefulWidget {
  final String loggedInUserEmail;

  DeliveredScreen({required this.loggedInUserEmail});

  @override
  _DeliveredScreenState createState() => _DeliveredScreenState();
}

class _DeliveredScreenState extends State<DeliveredScreen> {
  late Future<List<Order>> _confirmingOrdersFuture;
  int _rating = 0;
  String _comment = '';

  List<Order>? _confirmingOrders; // Declare confirmingOrders as a class-level variable

  @override
  void initState() {
    super.initState();
    _confirmingOrdersFuture = OrderService().getOrdersByStatusAndUserEmail('Delivered', widget.loggedInUserEmail);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đơn hàng đã giao'),
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
            _confirmingOrders = snapshot.data; // Assign the value to _confirmingOrders

            if (_confirmingOrders != null && _confirmingOrders!.isNotEmpty) {
              return ListView.builder(
                itemCount: _confirmingOrders!.length,
                itemBuilder: (context, index) {
                  Order order = _confirmingOrders![index];

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
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FutureBuilder<String?>(
                                future: UserService().getUserInfo(orderDetails.first.shopOwnerEmail),
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

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                                title: Text('Ngày đặt hàng: ${DateFormat('dd/MM/yyyy').format(order.orderDate)}'),
                                subtitle: Text('Tổng tiền: ${NumberFormat.currency(decimalDigits: 0, symbol: '').format(order.totalValue)}đ'),
                              ),
                              SizedBox(height: 8),
                              Divider(),
                              Column(
                                children: orderDetails.map((detail) {
                                  return ListTile(
                                    title: Text(detail.productName),
                                    subtitle: Text('Số lượng: ${detail.quantity} - Giá: ${NumberFormat.currency(decimalDigits: 0, symbol: '').format(detail.price)}đ'),
                                  );
                                }).toList(),
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (ratingIndex) {
                                  return IconButton(
                                    icon: Icon(
                                      ratingIndex < _rating ? Icons.star : Icons.star_border,
                                      color: Colors.amber,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _rating = ratingIndex + 1;
                                      });
                                    },
                                  );
                                }),
                              ),
                              SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: TextField(
                                  onChanged: (value) {
                                    // setState(() {
                                      _comment = value;
                                    // });
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Nhập comment của bạn...',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (_rating > 0) {
                                          confirmOrder(order);
                                          submitReview(index); // Pass the index to submitReview
                                        } else {
                                          print('Vui lòng chọn số sao!');
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.blue,
                                      ),
                                      child: Text('Đánh giá', style: TextStyle(color: Colors.black)),
                                    ),
                                  ),
                                ],
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
      await OrderService().updateOrderStatus(order.id, 'Reviewed');
      print('Confirmed order: ${order.id}');
    } catch (e) {
      print('Error confirming order: $e');
    }
  }

  void submitReview(int index) async {
    if (_rating > 0 && _comment.isNotEmpty && _confirmingOrders != null) {
      try {
        String userEmail = widget.loggedInUserEmail;
        DateTime timestamp = DateTime.now();

        for (int i = 0; i < _confirmingOrders!.length; i++) {
          Order? order = _confirmingOrders![i];
          List<OrderDetail>? orderDetails = order != null ? await OrderService().getOrderDetailsByOrderId(order.id) : null;

          if (order != null && orderDetails != null && orderDetails.isNotEmpty) {
            for (OrderDetail detail in orderDetails) {
              String productName = detail.productName;
              String shopOwnerEmail = detail.shopOwnerEmail;

              Review review = Review(
                rating: _rating,
                comment: _comment,
                userEmail: userEmail,
                productName: productName,
                shopOwnerEmail: shopOwnerEmail,
                timestamp: timestamp,
              );

              await ReviewService().saveReview(review);

              // Print a success message for each review saved
              print('Đánh giá cho sản phẩm $productName đã được lưu thành công.');
            }
          } else {
            print('Không thể lấy thông tin chi tiết đơn hàng hoặc đơn hàng.');
          }
        }

        setState(() {
          _rating = 0;
          _comment = '';
        });
      } catch (e) {
        print('Lỗi khi lưu đánh giá: $e');
      }
    } else {
      print('Vui lòng chọn số sao và nhập comment trước khi đánh giá.');
    }
  }

}
