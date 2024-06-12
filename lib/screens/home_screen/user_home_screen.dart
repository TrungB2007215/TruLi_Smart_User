import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../services/brand_service.dart';
import '../../services/category_service.dart';
import '../../services/product_service.dart';
import 'product_screen.dart';
import 'banner_carousel.dart';
import '../product/product_details_page.dart';
import '../brand/brands_page.dart';
import '../../widgets/star_rating.dart';
import '../../services/review_service.dart';
import '../../models/reviews_model.dart';

class UserHomeScreen extends StatelessWidget {
  final String loggedInUserEmail;
  final BrandService brandService = BrandService();
  final CategoryService categoryService = CategoryService();

  UserHomeScreen(this.loggedInUserEmail);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 10),
            BannerCarousel(),
            Container(
              margin: EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Danh mục',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            FutureBuilder<List<String>>(
              future: categoryService.getCategories(),
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
                  List<String> categories = snapshot.data ?? [];

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BrandsPage(
                                    categories: category, // Truyền categories thay vì selectedBrand
                                    loggedInUserEmail: loggedInUserEmail,
                                  ),
                                ),
                              );
                            },
                            child: Chip(
                              label: Text(category),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }
              },
            ),

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
              future: brandService.getBrands(),
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
              future: ProductService.getProducts(),
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
                    height: 300,
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
                                    Image.memory(imageBytes, width: 150, height: 150, fit: BoxFit.cover),
                                  SizedBox(height: 8),
                                  Text(productName, style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(formattedPrice != null ? ' $formattedPrice đ' : ''),
                                  _buildAverageRatingWidget(productName),
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
