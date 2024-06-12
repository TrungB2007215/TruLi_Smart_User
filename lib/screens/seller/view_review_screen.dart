import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import '../../services/review_service.dart';
import '../../services/product_service.dart';
import '../../models/reviews_model.dart';
import '../../widgets/star_rating.dart';


class ViewReviewScreen extends StatefulWidget {
  final String loggedInUserEmail;

  ViewReviewScreen({required this.loggedInUserEmail});

  @override
  _ViewReviewScreenState createState() => _ViewReviewScreenState();
}

class _ViewReviewScreenState extends State<ViewReviewScreen> {
  late Future<List<Review>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = _fetchReviews();
  }

  Future<List<Review>> _fetchReviews() async {
    try {
      List<Review> reviews = await ReviewService().getReviewsByShopOwner(userEmail: widget.loggedInUserEmail);
      return reviews;
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách đánh giá'),
      ),
      body: FutureBuilder<List<Review>>(
        future: _reviewsFuture,
        builder: (context, AsyncSnapshot<List<Review>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            List<Review> reviews = snapshot.data ?? [];

            if (reviews.isEmpty) {
              return Center(
                child: Text('Không có đánh giá nào.'),
              );
            }

            return ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(reviews[index].comment),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StarRating(rating: reviews[index].rating.toDouble()),
                      FutureBuilder<Map<String, dynamic>?>(
                        future: ProductService.getProductByNameAndShopOwnerEmail(
                          productName: reviews[index].productName,
                          shopOwnerEmail: widget.loggedInUserEmail,
                        ),
                        builder: (context, productSnapshot) {
                          if (productSnapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (productSnapshot.hasError || productSnapshot.data == null) {
                            return Text('Không tìm thấy sản phẩm'); // Handle error or null data
                          } else {
                            Map<String, dynamic> product = productSnapshot.data!;
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
                            );
                          }
                        },
                      ),
                      Text('Người dùng: ${reviews[index].userEmail}'),
                      Text('Ngày đánh giá: ${DateFormat('dd/MM/yyyy').format(reviews[index].timestamp)}'),

                      SizedBox(height: 8),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class ProductItemWidget extends StatelessWidget {
  final String productName;
  final Uint8List productImage;

  ProductItemWidget({required this.productName, required this.productImage});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(productName),
      leading: Image.memory(
        productImage,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      ),
      // Thêm các thành phần khác của sản phẩm ở đây
    );
  }
}
