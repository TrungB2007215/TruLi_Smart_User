import 'package:flutter/material.dart';
import '../models/catelogies_model.dart';

class CategoryList extends StatelessWidget {
  final List<Catelogies> categories;

  CategoryList({required this.categories});

  @override
  Widget build(BuildContext context) {
    // Sort categories alphabetically by name
    categories.sort((a, b) => a.name.compareTo(b.name));

    return categories.isEmpty
        ? Center(child: Text('Danh mục trống.'))
        : ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        Catelogies category = categories[index];
        return ListTile(
          title: Text(category.name),
          // You can customize the ListTile as needed
        );
      },
    );
  }
}
