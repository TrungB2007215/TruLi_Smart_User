import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import '../../services/address_service.dart';
import '../../services/info_user_service.dart';
import '../../services/product_service.dart';
import '../../services/cart_service.dart';
import 'edit_info_page.dart';

class OrderPage extends StatefulWidget {
  final String loggedInUserEmail;
  final List<DocumentSnapshot> selectedProducts;
  const OrderPage({Key? key, required this.loggedInUserEmail, required this.selectedProducts}) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  Map<String, dynamic> addressData = {};
  Map<String, dynamic> infoUserData = {};
  late double totalPrice = 0;

  @override
  void initState() {
    super.initState();
    loadData();
    calculateTotalPrice();
  }

  void calculateTotalPrice() {
    totalPrice = 0;
    for (var product in widget.selectedProducts) {
      double price = (product['price'] ?? 0) * (product['quantity'] ?? 1);
      totalPrice += price;
    }
  }

  Future<void> loadData() async {
    try {
      print(widget.loggedInUserEmail);
      Map<String, dynamic>? fetchedInfoData = await InfoUserService().getInfoUserByUserEmail(widget.loggedInUserEmail);

      if (fetchedInfoData != null) {
        infoUserData = fetchedInfoData;
        String addressId = infoUserData['address'];
        setState(() {});
        if (addressId != null && addressId.isNotEmpty) {
          Map<String, dynamic>? fetchedAddressData = await AddressService().getAddressById(addressId);
          if (fetchedAddressData != null) {
            addressData = fetchedAddressData;
            setState(() {calculateTotalPrice();});
          } else {
          }
        } else {
        }
      } else {
      }
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đặt hàng'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Thông tin nhận hàng:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditUserInfoPage(loggedInUserEmail: widget.loggedInUserEmail)),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              '${infoUserData?['recipientName'] ?? 'Tên người nhận'} | ${infoUserData?['phoneNumber'] ?? 'Số điện thoại'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 4),
            Text(
              '${addressData?['street'] ?? 'Địa chỉ'}\n${addressData?['ward'] ?? 'Phường/Xã'}, ${addressData?['district'] ?? 'Quận/Huyện'}, ${addressData?['province'] ?? 'Tỉnh/Thành phố'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Danh sách sản phẩm đã chọn:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: widget.selectedProducts.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot product = widget.selectedProducts[index];
                  return ListTile(
                    leading: FutureBuilder<Uint8List?>(
                      future: ProductService.getImageByName(product['productName']),
                      builder: (context, imageSnapshot) {
                        if (imageSnapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if (imageSnapshot.hasError || imageSnapshot.data == null) {
                          return SizedBox(
                            width: 100,
                            height: 100,
                            child: Icon(Icons.image),
                          );
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
                    title: Text(product['productName']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Số lượng: ${product['quantity']}'),
                        Text(
                          'Giá: ${NumberFormat.currency(decimalDigits: 0, symbol: '').format(product['price'])}đ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng tiền: ${NumberFormat.currency(decimalDigits: 0, symbol: '').format(totalPrice)}đ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: _tackOder,
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                ),
                child: Text(
                  'Đặt hàng',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  void _tackOder() async {
    try {
      DocumentReference orderRef = await FirebaseFirestore.instance.collection('orders').add({
        'userEmail': widget.loggedInUserEmail,
        'addressId': infoUserData['address'],
        'totalValue': totalPrice,
        'orderDate': Timestamp.now(),
        'orderStatus': 'Confirming',
      });

      for (var product in widget.selectedProducts) {
        await FirebaseFirestore.instance.collection('order_details').add({
          'orderId': orderRef.id,
          'productName': product['productName'],
          'shopOwnerEmail': product['shopOwnerEmail'],
          'price': product['price'],
          'quantity': product['quantity'],
        });
      }

      await CartService().removeSelectedProducts(widget.selectedProducts, widget.loggedInUserEmail);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Đặt hàng thành công!'),
        duration: Duration(seconds: 2),
      ));

      Navigator.pop(context);

    } catch (e) {
      print('Error placing order: $e');
      // Xử lý khi có lỗi xảy ra
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Đã xảy ra lỗi khi đặt hàng! Vui lòng thử lại sau.'),
        duration: Duration(seconds: 2),
      ));
    }
  }


}
