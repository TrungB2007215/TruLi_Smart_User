import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import '../../widgets/star_rating.dart';
import '../../services/product_service.dart';
import '../../services/technical_specifications_service.dart';
import '../../services/import_service.dart';
import '../../services/cart_service.dart';
import '../../services/review_service.dart'; // Import review service
import '../../models/reviews_model.dart'; // Import Review model

class ProductDetailsPage extends StatefulWidget {
  final String products;
  final String loggedInUserEmail;

  ProductDetailsPage({required this.products, required this.loggedInUserEmail});

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late Future<Map<String, dynamic>?> _technicalSpecsFuture;
  late Future<double?> _averageRatingFuture;
  late Future<List<Review>> _reviewsFuture;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _technicalSpecsFuture =
        TechnicalSpecificationsService().getTechnicalSpecifications(widget.products);
    _averageRatingFuture = _calculateAverageRating();
    _reviewsFuture = _fetchReviews();
  }

  Future<double?> _calculateAverageRating() async {
    try {
      double totalRating = 0;
      int totalReviews = 0;

      // Get reviews by user email and product name
      List<Review> reviews = await ReviewService().getReviewsByUserAndProduct(
        userEmail: widget.loggedInUserEmail,
        productName: widget.products,
      );

      if (reviews.isNotEmpty) {
        for (var review in reviews) {
          totalRating += review.rating!;
          totalReviews++;
        }
        // Calculate average rating
        return totalRating / totalReviews;
      } else {
        return null; // Return null if there are no reviews
      }
    } catch (e) {
      print('Error calculating average rating: $e');
      return null;
    }
  }

  Future<List<Review>> _fetchReviews() async {
    try {
      return ReviewService().getReviewsByUserAndProduct(
        userEmail: widget.loggedInUserEmail,
        productName: widget.products,
      );
    } catch (e) {
      print('Error fetching reviews: $e');
      return []; // Return empty list in case of error
    }
  }

  Widget _buildAverageRating(double? averageRating) {
    if (averageRating != null) {
      return Row(
        children: [
          StarRating(rating: averageRating), // Sử dụng StarRating widget
          SizedBox(width: 8), // Khoảng cách giữa sao và số xếp hạng
          // Text(
            // '${averageRating.toStringAsFixed(1)}',
            // style: TextStyle(fontSize: 18),
          // ),
        ],
      );
    } else {
      return Text('Chưa có đánh giá nào');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết sản phẩm'),
      ),
      body: Container(
        color: Colors.white,
        child: FutureBuilder(
          future: _technicalSpecsFuture,
          builder: (context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              Map<String, dynamic>? technicalSpecs = snapshot.data;

              if (technicalSpecs == null) {
                return Center(
                  child: Text('No data available'),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: SizedBox(
                        height: 200,
                        child: FutureBuilder(
                          future: _getImageByName(),
                          builder: (context, AsyncSnapshot<String?> imageSnapshot) {
                            if (imageSnapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (imageSnapshot.hasError) {
                              return Text('Error: ${imageSnapshot.error}');
                            } else {
                              String? imageString = imageSnapshot.data;
                              if (imageString != null) {
                                return _displayImage(imageString);
                              } else {
                                return Text('No image available');
                              }
                            }
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${widget.products}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FutureBuilder(
                        future: _getPriceByName(),
                        builder: (context, AsyncSnapshot<double?> priceSnapshot) {
                          if (priceSnapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (priceSnapshot.hasError) {
                            return Text('Error: ${priceSnapshot.error}', style: TextStyle(fontSize: 18));
                          } else {
                            double? price = priceSnapshot.data;
                            final formattedPrice = NumberFormat.currency(decimalDigits: 0, symbol: '').format(price ?? 0);
                            return Text(
                              'Giá bán: $formattedPrice VND',
                              style: TextStyle(fontSize: 18),
                            );
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FutureBuilder(
                        future: _averageRatingFuture,
                        builder: (context, AsyncSnapshot<double?> averageRatingSnapshot) {
                          if (averageRatingSnapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (averageRatingSnapshot.hasError) {
                            return Text('Error: ${averageRatingSnapshot.error}');
                          } else {
                            double? averageRating = averageRatingSnapshot.data;
                            return _buildAverageRating(averageRating);
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: buildTechnicalSpecs(technicalSpecs),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Đánh giá và bình luận',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    FutureBuilder(
                      future: _reviewsFuture,
                      builder: (context, AsyncSnapshot<List<Review>> reviewsSnapshot) {
                        if (reviewsSnapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (reviewsSnapshot.hasError) {
                          return Center(child: Text('Lỗi: ${reviewsSnapshot.error}'));
                        } else {
                          List<Review> reviews = reviewsSnapshot.data ?? [];

                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: reviews.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(reviews[index].comment),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildAverageRating(reviews[index].rating.toDouble()),
                                    SizedBox(height: 4),
                                    Text('Người dùng: ${reviews[index].userEmail}'),
                                    Text('Ngày đánh giá: ${DateFormat('dd/MM/yyyy').format(reviews[index].timestamp)}'),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FutureBuilder<int>(
              future: ImportService().getTotalQuantityInStock(widget.products),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Text('Số lượng trong kho: ${snapshot.data}');
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: () {
                  _showAddToCartBottomSheet();
                },
                icon: Icon(Icons.shopping_cart_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTechnicalSpecs(Map<String, dynamic> technicalSpecs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            'Thông số kỹ thuật',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
        ),
        if (isExpanded)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTechnicalSpec('CPU', technicalSpecs['processor']),
              buildTechnicalSpec('RAM', technicalSpecs['ram']),
              buildTechnicalSpec('Ổ cứng', technicalSpecs['rom']),
              buildTechnicalSpec('Card màn hình', technicalSpecs['graphicsCard']),
              buildTechnicalSpec('Hệ điều hành', technicalSpecs['operatingSystem']),
              buildTechnicalSpec('Màn hình', technicalSpecs['screenSize']),
              buildTechnicalSpec('Tần số quét', technicalSpecs['camera']),
              buildTechnicalSpec('Pin - Công suất sạc', technicalSpecs['batteryCapacity']),
              buildTechnicalSpec('Trọng lượng', technicalSpecs['weight']),
            ],
          ),
      ],
    );
  }

  Widget buildTechnicalSpec(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Text(
        '$label: $value',
        // style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _displayImage(String imageString) {
    Uint8List imageBytes = base64Decode(imageString);
    return Image.memory(
      imageBytes,
      width: 350,
      fit: BoxFit.cover,
    );
  }

  Future<String?> _getImageByName() async {
    try {
      Uint8List? imageBytes = await ProductService.getImageByName(widget.products);
      if (imageBytes != null) {
        return base64Encode(imageBytes);
      }
      return null;
    } catch (e) {
      print('Error getting image by name: $e');
      return null;
    }
  }

  Future<double?> _getPriceByName() async {
    try {
      double? sellingPrice = await ProductService.getPriceByName(widget.products);
      return sellingPrice;
    } catch (e) {
      print('Error getting price by name: $e');
      return null;
    }
  }

  void _showAddToCartBottomSheet() {
    int selectedQuantity = 1;
    int totalQuantityInStock = 0;

    ImportService().getTotalQuantityInStock(widget.products).then((value) {
      setState(() {
        totalQuantityInStock = value;
      });
    });

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Chọn số lượng (Tồn kho: $totalQuantityInStock)'),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          if (selectedQuantity > 1) {
                            setState(() {
                              selectedQuantity--;
                            });
                          }
                        },
                      ),
                      Text(
                        selectedQuantity.toString(),
                        style: TextStyle(fontSize: 18),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          if (selectedQuantity < totalQuantityInStock) {
                            setState(() {
                              selectedQuantity++;
                            });
                          } else {
                            // Hiển thị thông báo khi số lượng vượt quá tổng số lượng trong kho
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Số lương sản phẩm còn lại không đủ để đáp ứng nhu cầu mua hàng của bạn.'),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedQuantity <= totalQuantityInStock) {
                        _addToCart(selectedQuantity);
                        Navigator.pop(context);
                      } else {
                        // Hiển thị thông báo khi số lượng vượt quá tổng số lượng trong kho
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Số lượng sản phẩm không đủ đáp ứng nhu cầu của bạn.'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                    ),
                    child: Text(
                      'Thêm vào giỏ hàng',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  void _addToCart(int quantity) async {
    String shopOwnerEmail = await ImportService().getShopOwnerEmail(widget.products);
    double? price = await _getPriceByName();

    if (shopOwnerEmail.isNotEmpty && price != null) {
      CartService cartService = CartService();
      cartService.getUserCartItems(widget.loggedInUserEmail).then((cartItems) {
        bool productExistsInCart = false;
        String cartItemId = '';

        for (var cartItem in cartItems) {
          if (cartItem['productName'] == widget.products) {
            productExistsInCart = true;
            cartItemId = cartItem.id;
            break;
          }
        }

        if (productExistsInCart) {
          int currentQuantity = cartItems.firstWhere((item) => item.id == cartItemId)['quantity'];
          cartService.updateCartItemQuantity(cartItemId, currentQuantity + quantity).then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Số lượng sản phẩm đã được cập nhật trong giỏ hàng.'),
              ),
            );
          });
        } else {
          cartService.addToCart(
            userEmail: widget.loggedInUserEmail,
            productName: widget.products,
            price: price,
            quantity: quantity,
            shopOwnerEmail: shopOwnerEmail,
          ).then((success) {
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Sản phẩm đã đươc thêm vào giỏ hàng.'),
                ),
              );
            } else {
              print('Failed to add to cart');
            }
          });
        }
      });
    } else {
      print('Failed to retrieve shop owner email or product price');
    }
  }
}

