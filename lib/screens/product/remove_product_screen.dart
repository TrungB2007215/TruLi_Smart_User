import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import '../../services/product_service.dart';
import '../../services/cart_service.dart';
class RemoveProductScreen extends StatefulWidget {
  final String loggedInUserEmail;

  const RemoveProductScreen({required this.loggedInUserEmail});

  @override
  _RemoveProductScreenState createState() => _RemoveProductScreenState();
}

class _RemoveProductScreenState extends State<RemoveProductScreen> {
  final ProductService productService = ProductService();
  final CartService cartService = CartService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Xóa sản phẩm'),
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
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _showConfirmationDialog(productName);
                    },
                  ),
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

  Future<void> _showConfirmationDialog(String productName) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Bạn có muốn xóa $productName?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Xóa'),
              onPressed: () {
                _removeProduct(productName);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeProduct(String productName) async {
    bool success = await productService.deleteProduct(productName);
    if (success) {
      // Product removed successfully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$productName dược xóa thành công.'),
        ),
      );
      productService.deleteProduct(productName).then((_) {
        cartService.checkProductExists(productName).then((cartExists) {
          if (cartExists) {
            cartService.deleteProductFromCarts(productName);
          }
        });
      });

      setState(() {});
    } else {
      // Failed to remove product
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi xóa $productName.'),
        ),
      );
    }
  }

}
