import 'package:flutter/material.dart';
import '../services/category_service.dart';
class CategorySelectionWidget extends StatefulWidget {
  @override
  _CategorySelectionWidgetState createState() => _CategorySelectionWidgetState();
}

class _CategorySelectionWidgetState extends State<CategorySelectionWidget> {
  final CategoryService _categoryService = CategoryService();
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    List<String> loadedCategories = await _categoryService.getCategories();
    setState(() {
      categories = loadedCategories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chọn danh mục'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton(
              items: categories
                  .map((category) => DropdownMenuItem(
                value: category,
                child: Text(category),
              ))
                  .toList(),
              onChanged: (value) {
                // Xử lý khi người dùng chọn danh mục
              },
              hint: Text('Chọn danh mục'),
            ),
            // Các thành phần giao diện khác
          ],
        ),
      ),
    );
  }
}
