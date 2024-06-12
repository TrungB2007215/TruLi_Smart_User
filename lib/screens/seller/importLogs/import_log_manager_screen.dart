import 'package:flutter/material.dart';
import '../../../utils/routes.dart';

class LogManagerScreen extends StatefulWidget {

  final String loggedInUserEmail;

  const LogManagerScreen({Key? key, required this.loggedInUserEmail}) : super(key: key);
  @override
  _LogManagerScreenState createState() => _LogManagerScreenState();
}

class _LogManagerScreenState extends State<LogManagerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nhập hàng'),
        backgroundColor: Colors.yellow,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to View All Logs Screen
              Navigator.pushNamed(context, Routes.viewAllLogs, arguments: widget.loggedInUserEmail);
            },
            icon: Icon(Icons.view_list, size: 30),
            label: Text(
              'Xem tất cả lô hàng',
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
              Navigator.pushNamed(
                context,
                Routes.importLogs,
                arguments: widget.loggedInUserEmail,
              );
            },
            icon: Icon(Icons.add, size: 30),
            label: Text(
              'Nhập hàng',
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
              Navigator.pushNamed(context, Routes.addQuantity, arguments: widget.loggedInUserEmail);
            },
            icon: Icon(Icons.add_circle, size: 30), // Icon for adding quantity
            label: Text(
              'Thêm số lượng',
              style: TextStyle(fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.orange, // Button background color
              onPrimary: Colors.white, // Button text color
              padding: EdgeInsets.all(20), // Set custom padding size
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to Remove Log Screen
              Navigator.pushNamed(context, Routes.removeLog, arguments: widget.loggedInUserEmail,);
            },
            icon: Icon(Icons.delete, size: 30),
            label: Text(
              'Xóa lô hàng',
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
