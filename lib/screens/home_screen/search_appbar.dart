import 'package:flutter/material.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final VoidCallback turnOffSearchResultsPage; // Hàm callback để tắt SearchResultsPage

  SearchAppBar({Key? key, required this.controller, required this.onSearch, required this.turnOffSearchResultsPage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: TextField(
        controller: controller,
        onChanged: onSearch,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm...',
          border: InputBorder.none,
        ),
      ),
      actions: [
        // Hiển thị nút đóng hoặc nút tìm kiếm tùy thuộc vào việc có dữ liệu tìm kiếm hay không
        if (controller.text.isNotEmpty)
          IconButton(
            onPressed: () {
              controller.clear();
              onSearch('');
              // Gọi hàm callback để tắt SearchResultsPage
              turnOffSearchResultsPage();
            },
            icon: Icon(Icons.close),
          ),
        if (controller.text.isEmpty)
          IconButton(
            onPressed: () {
              // Xử lý khi người dùng nhấn vào nút tìm kiếm
            },
            icon: Icon(Icons.search),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}


