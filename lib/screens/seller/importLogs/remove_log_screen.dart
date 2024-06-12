import 'package:flutter/material.dart';
import '../../../services/import_service.dart';
import '../../../services/product_service.dart';
import '../../../services/cart_service.dart';

class RemoveLogScreen extends StatefulWidget {
  final String loggedInUserEmail;

  const RemoveLogScreen({Key? key, required this.loggedInUserEmail}) : super(key: key);

  @override
  _RemoveLogScreenState createState() => _RemoveLogScreenState();
}

class _RemoveLogScreenState extends State<RemoveLogScreen> {
  final ImportService importService = ImportService();
  final ProductService productService = ProductService();
  final CartService cartService = CartService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Xóa lô hàng'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: importService.getImportLogWithEmail(widget.loggedInUserEmail),
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
                Map<String, dynamic> log = snapshot.data![index];
                return ListTile(
                  title: Text(log['productName']),
                  subtitle: Text('Kho: ${log['quantity']}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _showConfirmationDialog(log['productName']);
                    },
                  ),
                );
              },
            );
          }
          return Center(
            child: Text('Không có dữ liệu nhập hàng.'),
          );
        },
      ),
    );
  }

  Future<void> _showConfirmationDialog(String productName) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Bạn có muốn xóa $productName?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Xóa'),
              onPressed: () {
                _removeLog(productName);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _removeLog(String productName) {
    importService.removeImportLog(productName).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bạn xoá lô hàng thành công.'),
          ),
        );

        productService.checkProductExists(productName).then((exists) {
          if (exists) {
            productService.deleteProduct(productName).then((_) {
              cartService.checkProductExists(productName).then((cartExists) {
                if (cartExists) {
                  cartService.deleteProductFromCarts(productName);
                }
              });
            });
          }
        });
        Future.delayed(Duration(seconds: 2)).then((_) {
          Navigator.pop(context);
        });
      }
    });
  }
}
