import 'package:flutter/material.dart';
import '../../services/product_service.dart';
import 'dart:typed_data';
import 'dart:convert';
import '../product/product_details_page.dart';
import 'package:intl/intl.dart';
import '../../widgets/star_rating.dart';
import '../../services/review_service.dart';
import '../../models/reviews_model.dart';

class ProductScreen extends StatelessWidget {
  final String selectedBrand;
  final String loggedInUserEmail;
  final ProductService productService = ProductService();
  final ReviewService reviewService = ReviewService(); // Khởi tạo ReviewService

  ProductScreen({required this.selectedBrand, required this.loggedInUserEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sản phẩm của $selectedBrand'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ProductService.getProductsByOneBrand(selectedBrand),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            List<Map<String, dynamic>> products = snapshot.data ?? [];
            return Container(
              height: 200, // Set a fixed height for the container
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> product = products[index];
                  String productName = product['name'] ?? '';
                  double? sellingPrice = product['sellingPrice'];
                  List<dynamic> imageData = product['images'];
                  Uint8List? imageBytes;

                  if (imageData != null && imageData.isNotEmpty) {
                    imageBytes = Uint8List.fromList(imageData.cast<int>());
                  }

                  final formattedPrice = NumberFormat.currency(decimalDigits: 0, symbol: '').format(sellingPrice ?? 0);

                  return FutureBuilder<List<Review>>(
                    future: reviewService.getReviewsByProductName(product['name']),
                    builder: (context, reviewSnapshot) {
                      if (reviewSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (reviewSnapshot.hasError) {
                        return Center(
                          child: Text('Error: ${reviewSnapshot.error}'),
                        );
                      } else {
                        List<Review> reviews = reviewSnapshot.data ?? [];
                        double? averageRating = _calculateAverageRating(reviews);

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailsPage(
                                  products: productName,
                                  loggedInUserEmail: loggedInUserEmail,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            margin: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (imageBytes != null)
                                    Image.memory(imageBytes, width: 100, height: 100, fit: BoxFit.cover),
                                  SizedBox(height: 8),
                                  Text(productName, style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(formattedPrice != null ? ' $formattedPrice đ' : ''),
                                  _buildAverageRating(averageRating),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildAverageRating(double? averageRating) {
    if (averageRating != null) {
      return Row(
        children: [
          StarRating(rating: averageRating),
          SizedBox(width: 8),

        ],
      );
    } else {
      return Text('Chưa có đánh giá nào');
    }
  }

  double? _calculateAverageRating(List<Review> reviews) {
    if (reviews.isEmpty) return null;

    double totalRating = 0;
    for (var review in reviews) {
      totalRating += review.rating;
    }
    return totalRating / reviews.length;
  }
}

