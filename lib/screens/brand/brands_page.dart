import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/brand_service.dart';
import '../../services/product_service.dart';
import '../product/product_details_page.dart';
import '../home_screen/product_screen.dart';

import '../../services/review_service.dart';
import '../../models/reviews_model.dart';
import '../../widgets/star_rating.dart';


class BrandsPage extends StatelessWidget {
  final String categories;
  final String loggedInUserEmail;

  BrandsPage({required this.categories, required this.loggedInUserEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$categories'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thương hiệu
          Container(
            margin: EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Thương hiệu',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          FutureBuilder<List<String>>(
            future: BrandService.getBrandsContainingCategories(categories),
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
                List<String> brands = snapshot.data ?? [];

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: brands.map((brand) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductScreen(
                                  selectedBrand: brand,
                                  loggedInUserEmail: loggedInUserEmail,
                                ),
                              ),
                            );
                          },
                          child: Chip(
                            label: Text(brand),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }
            },
          ),
          // Sản phẩm
          Container(
            margin: EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Sản phẩm',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: ProductService.getProductsContainingCategory(categories),
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
                  height: 550, // Set a fixed height for the container
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

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailsPage(products: productName, loggedInUserEmail: loggedInUserEmail),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          margin: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (imageBytes != null)
                                  Image.memory(imageBytes, width: 150, height: 150, fit: BoxFit.cover),
                                SizedBox(height: 8),
                                Text(productName, style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(formattedPrice != null ? ' $formattedPrice đ' : ''),
                                _buildAverageRatingWidget(productName), // Hiển thị đánh giá trung bình
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAverageRatingWidget(String productName) {
    final ReviewService reviewService = ReviewService();
    return FutureBuilder<List<Review>>(
      future: reviewService.getReviewsByProductName(productName),
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

          return averageRating != null
              ? _buildAverageRating(averageRating)
              : Text('Chưa có đánh giá');
        }
      },
    );
  }

  Widget _buildAverageRating(double averageRating) {
    return Row(
      children: [
        StarRating(rating: averageRating),
        SizedBox(width: 8),
      ],
    );
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

