import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import '../../services/product_service.dart';
import 'product_details_page.dart';

class ViewAllProductScreen extends StatefulWidget {
  final String loggedInUserEmail;

  const ViewAllProductScreen({required this.loggedInUserEmail});

  @override
  _ViewAllProductScreenState createState() => _ViewAllProductScreenState();
}

class _ViewAllProductScreenState extends State<ViewAllProductScreen> {
  final ProductService productService = ProductService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tất cả sản phẩm'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: productService.getAllProductWithEmail(widget.loggedInUserEmail),
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
                String productName = product['name'] ?? '';
                double? sellingPrice = product['sellingPrice'];
                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsPage(
                            products: productName,
                            loggedInUserEmail: widget.loggedInUserEmail),
                      ),
                    );
                  },
                  leading: FutureBuilder<Uint8List?>(
                    future: ProductService.getImageByName(productName),
                    builder: (context, imageSnapshot) {
                      if (imageSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (imageSnapshot.hasError ||
                          imageSnapshot.data == null) {
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
      ),
    );
  }
}
