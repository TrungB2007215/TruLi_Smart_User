import 'package:flutter/material.dart';
import '../../models/product.dart'; // Import Product model

class ProductList extends StatelessWidget {
  final List<String> products;

  const ProductList({Key? key, required this.products}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: products.map((product) => Text(product)).toList(),
    );
  }
}
