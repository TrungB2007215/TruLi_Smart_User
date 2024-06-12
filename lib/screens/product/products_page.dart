import 'package:flutter/material.dart';

class ProductsPage extends StatelessWidget {
  final List<String> brands;

  ProductsPage({required this.brands});

  @override
  Widget build(BuildContext context) {
    // Triển khai giao diện hiển thị danh sách sản phẩm dựa vào brands
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
      ),
      body: ListView.builder(
        itemCount: brands.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(brands[index]),
            onTap: () {
              // Xử lý khi một sản phẩm được chọn
            },
          );
        },
      ),
    );
  }
}
