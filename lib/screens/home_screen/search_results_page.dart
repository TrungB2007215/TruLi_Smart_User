import 'package:flutter/material.dart';
import '../brand/brands_page.dart';
import '../product/products_page.dart';
import '../product/product_details_page.dart';
import '../category/category_list.dart';
import '../brand/brand_list.dart';
import '../product/product_list.dart';
import 'product_screen.dart';

class SearchResultsPage extends StatelessWidget {
  final List<String> _categories;
  final List<String> _brands;
  final List<String> _products;
  final String loggedInUserEmail;

  SearchResultsPage({
    required List<String> categories,
    required List<String> brands,
    required List<String> products,
    required this.loggedInUserEmail
  })  : _categories = categories,
        _brands = brands,
        _products = products;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 20.0), // Đặt margin bên trái để căn lề
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () async {
              String? selectedCategory = await _showSelectionDialog(context, _categories, 'Chọn danh mục');
              if (selectedCategory != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BrandsPage(categories: selectedCategory, loggedInUserEmail: loggedInUserEmail)),
                );
              }
            },
            child: CategoryList(categories: _categories),
          ),
          GestureDetector(
            onTap: () async {
              // Chọn một trong hai kết quả trả về từ phần nhãn hiệu
              String? selectedBrand = await _showSelectionDialog(context, _brands, 'Chọn nhãn hiệu');
              if (selectedBrand != null) {
                // Chuyển hướng đến trang hiển thị danh sách sản phẩm
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductScreen(selectedBrand: selectedBrand, loggedInUserEmail: loggedInUserEmail,)),
                );
              }
            },
            child: BrandList(brands: _brands),
          ),
          GestureDetector(
            onTap: () async {
              // Chọn một trong các sản phẩm
              String? selectedProduct = await _showSelectionDialog(context, _products, 'Chọn sản phẩm');
              if (selectedProduct != null) {
                // Chuyển hướng đến trang hiển thị chi tiết sản phẩm
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductDetailsPage(products: selectedProduct, loggedInUserEmail: loggedInUserEmail,)),
                );
              }
            },
            child: ProductList(products: _products),
          ),
        ],
      ),
    );
  }

  // Hiển thị hộp thoại cho phép người dùng chọn một trong các mục
  Future<String?> _showSelectionDialog(BuildContext context, List<String> items, String title) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: items.map((item) {
              return ListTile(
                title: Text(item),
                onTap: () {
                  Navigator.of(context).pop(item);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
