import 'package:flutter/material.dart';
import '../../utils/routes.dart';

class ProductManagerScreen extends StatelessWidget {
  final String loggedInUserEmail;

  const ProductManagerScreen({Key? key, required this.loggedInUserEmail}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý sản phẩm'),
        backgroundColor: Colors.yellow,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to View All Brands Screen
              Navigator.pushNamed(context, Routes.viewAllProduct, arguments: loggedInUserEmail);
            },
            icon: Icon(Icons.view_list, size: 30),
            label: Text(
              'Xem tất cả sản phẩm',
              style: TextStyle(fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.blue, // Màu nền của nút
              onPrimary: Colors.white, // Màu chữ của nút
              padding: EdgeInsets.all(20), // Đặt kích thước padding tùy chỉnh
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, Routes.addProduct, arguments: loggedInUserEmail);
            },
            icon: Icon(Icons.add, size: 30),
            label: Text(
              'Thêm sản phẩm mới',
              style: TextStyle(fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.green, // Button background color
              onPrimary: Colors.white, // Button text color
              padding: EdgeInsets.all(20), // Set custom padding size
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to Remove Product Screen
              Navigator.pushNamed(context, Routes.removeProduct);
            },
            icon: Icon(Icons.delete, size: 30),
            label: Text(
              'Xóa sản phẩm',
              style: TextStyle(fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.red, // Button background color
              onPrimary: Colors.white, // Button text color
              padding: EdgeInsets.all(20), // Set custom padding size
            ),
          ),
        ],
      ),
    );
  }
}
