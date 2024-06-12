import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import '../../services/product_service.dart';

class ProductListView extends StatelessWidget {
  final String loggedInUserEmail;

  const ProductListView({required this.loggedInUserEmail});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ProductService().getAllProductWithEmail(loggedInUserEmail),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> product = snapshot.data![index];
              String productName = product['name'] ?? ''; // Handle null case
              double? sellingPrice = product['sellingPrice']; // Handle null case
              return ListTile(
                leading: FutureBuilder<Uint8List?>(
                  future: ProductService.getImageByName(productName),
                  builder: (context, imageSnapshot) {
                    if (imageSnapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (imageSnapshot.hasError || imageSnapshot.data == null) {
                      return Container();
                    }
                    return SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.memory(
                        imageSnapshot.data!,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
                title: Text(productName),
                subtitle: sellingPrice != null
                    ? Text(
                  '${NumberFormat.currency(decimalDigits: 0, symbol: '').format(sellingPrice)}đ',
                  style: TextStyle(fontSize: 16),
                )
                    : Text('Price not available'),
              );
            },
          );
        }
        return Center(
          child: Text('Không có sản phẩm nào.'),
        );
      },
    );
  }
}
