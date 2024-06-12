import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/cart_service.dart';
import '../../services/product_service.dart';
import '../../utils/routes.dart';
import '../../screens/oder/orders_screen.dart';

class ShoppingCartScreen extends StatefulWidget {
  final String loggedInUserEmail;

  ShoppingCartScreen(this.loggedInUserEmail);

  @override
  _ShoppingCartScreenState createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  final CartService cartService = CartService();
  late double totalPrice = 0;
  late List<bool> checkedItems = [];
  List<DocumentSnapshot> selectedProducts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Giỏ hàng'),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: cartService.getUserCartItems(widget.loggedInUserEmail),
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
            if (checkedItems.isEmpty) {
              checkedItems = List.generate(snapshot.data!.length, (index) => false);
            }
            totalPrice = 0;
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = snapshot.data![index];
                double itemPrice = (document['price'] ?? 0) * (document['quantity'] ?? 1);
                if (checkedItems[index]) {
                  totalPrice += itemPrice;
                }
                return Dismissible(
                  key: Key(document.id),
                  direction: DismissDirection.startToEnd,
                  background: Container(
                    alignment: Alignment.centerLeft,
                    color: Colors.red,
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    setState(() {
                      cartService.deleteCartItem(document.id);
                      snapshot.data!.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Đã xóa sản phẩm khỏi giỏ hàng"),
                        action: SnackBarAction(
                          label: 'Hoàn tác',
                          onPressed: () {
                            setState(() {
                              cartService.restoreCartItem(document.id, document.data() as Map<String, dynamic>);
                              snapshot.data!.insert(index, document);
                            });
                          },
                        ),
                      ),
                    );
                  },
                  child: FutureBuilder<Uint8List?>(
                    future: ProductService.getImageByName(document['productName']),
                    builder: (context, imageSnapshot) {
                      if (imageSnapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (imageSnapshot.hasError || imageSnapshot.data == null) {
                        return Container();
                      }
                      return ListTile(
                        leading: Checkbox(
                          value: checkedItems[index],
                          onChanged: (value) {
                            setState(() {
                              checkedItems[index] = value!;
                              if (value!) {
                                selectedProducts.add(snapshot.data![index]);
                                totalPrice += itemPrice;
                              } else {
                                selectedProducts.remove(snapshot.data![index]);
                                totalPrice -= itemPrice;
                              }
                            });
                          },
                        ),
                        title: Row(
                          children: [
                            SizedBox(
                              width: 100,
                              child: Image.memory(
                                imageSnapshot.data!,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    document['productName'],
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    NumberFormat.currency(decimalDigits: 0, symbol: '').format(document['price']) + 'đ',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () {
                                    int quantity = document['quantity'] as int;
                                    if (quantity > 1) {
                                      updateCartItemQuantity(document.id, quantity - 1);
                                      setState(() {
                                        quantity -= 1;
                                        totalPrice -= (document['price'] ?? 0);
                                      });
                                    }
                                  },
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Center(
                                    child: Text(
                                      '${document['quantity']}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    int quantity = document['quantity'] as int;
                                    updateCartItemQuantity(document.id, quantity + 1);
                                    setState(() {
                                      quantity += 1;
                                      totalPrice += (document['price'] ?? 0);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            );

          }
          return Center(
            child: Text('Không có sản phẩm trong giỏ hàng của bạn.'),
          );
        },
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OrderPage(
                      loggedInUserEmail: widget.loggedInUserEmail,
                      selectedProducts: selectedProducts,
                    )),
                  );

                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                ),
                child: Text(
                  'Mua hàng',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateCartItemQuantity(String cartItemId, int newQuantity) {
    cartService.updateCartItemQuantity(cartItemId, newQuantity);
  }
}
