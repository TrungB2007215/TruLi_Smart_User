import 'package:flutter/material.dart';
import '../../models/catelogies_model.dart'; // Import Category model

class CategoryList extends StatelessWidget {
  final List<String> categories;

  const CategoryList({Key? key, required this.categories}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categories.map((category) => Text(category)).toList(),
    );
  }
}