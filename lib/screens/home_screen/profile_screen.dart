import 'package:flutter/material.dart';
import '../../utils/routes.dart';
import '../../services/order_service.dart';
import '../../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  final String loggedInUserEmail;

  ProfileScreen({required this.loggedInUserEmail});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final OrderService _orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.register);
                    },
                    icon: Icon(Icons.person_add, size: 35),
                    label: Text(
                      'Đăng ký',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      onPrimary: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.login);
                    },
                    icon: Icon(Icons.logout, size: 35),
                    label: Text(
                      'Đăng xuất',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      onPrimary: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lịch sử mua hàng',
                    style: TextStyle(fontSize: 18),
                  ),
                  IconButton(
                    icon: Icon(Icons.history),
                    onPressed: () {
                      // Add action for "Xem lịch sử mua hàng" button here
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildOrderStatusButton(
                      iconData: Icons.folder,
                      text: 'Chờ xác nhận',
                      future: _orderService.getOrderCountByStatus(
                          'Confirming', widget.loggedInUserEmail),
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.confirming);
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildOrderStatusButton(
                      iconData: Icons.local_shipping,
                      text: 'Chờ giao hàng',
                      future: _orderService.getOrderCountByStatus(
                          'Confirmed', widget.loggedInUserEmail),
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.confirmed);
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildOrderStatusButton(
                      iconData: Icons.star,
                      text: 'Đánh giá',
                      future: _orderService.getOrderCountByStatus(
                          'Delivered', widget.loggedInUserEmail),
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.delivered);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  _registerAsSeller();
                },
                icon: Icon(Icons.person_add, size: 35),
                label: Text(
                  'Đăng ký người bán hàng',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  onPrimary: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _registerAsSeller() {
    UserService().getRole(widget.loggedInUserEmail).then((role) {
      print(role);
      if (role == 'user') {
        UserService()
            .updateUserRole(widget.loggedInUserEmail, 'confirming_seller')
            .then((success) {
          if (success) {
            // Nếu cập nhật thành công, hiển thị thông báo và cập nhật giao diện
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã đăng ký thành người bán hàng!')));
            setState(() {});
          } else {
            // Nếu cập nhật không thành công, hiển thị thông báo lỗi
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Đăng ký không thành công. Vui lòng thử lại!')));
          }
        }).catchError((error) {
          // Xử lý lỗi trong quá trình cập nhật role
          print('Đã xảy ra lỗi: $error');
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đã xảy ra lỗi. Vui lòng thử lại sau!')));
        });
      } else {
        // Nếu role không phải là 'user', không thực hiện cập nhật và hiển thị thông báo
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Không thể đăng ký!')));
      }
    }).catchError((error) {
      // Xử lý lỗi trong quá trình lấy thông tin role
      print('Đã xảy ra lỗi khi lấy role: $error');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xảy ra lỗi. Vui lòng thử lại sau!')));
    });
  }

  Widget _buildOrderStatusButton({
    required IconData iconData,
    required String text,
    required Future<int> future,
    required VoidCallback onPressed,
  }) {
    return FutureBuilder<int>(
      future: future,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        return Column(
          children: [
            Stack(
              children: [
                Icon(
                  iconData,
                  size: 40,
                  color: Color.fromRGBO(58, 57, 57, 1.0),
                ),
                if (count > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: onPressed,
              child: Text(
                'Xem chi tiết',
                style: TextStyle(fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                onPrimary: Color.fromRGBO(58, 57, 57, 1.0),
                minimumSize: Size(120, 40),
              ),
            ),
            SizedBox(height: 20),
          ],
        );
      },
    );
  }
}
