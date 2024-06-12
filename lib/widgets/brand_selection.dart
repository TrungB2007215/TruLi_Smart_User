import 'package:flutter/material.dart';
import '../services/brand_service.dart'; // Thay your_project_name bằng tên dự án của bạn

class BrandSelectionWidget extends StatefulWidget {
  @override
  _BrandSelectionWidgetState createState() => _BrandSelectionWidgetState();
}

class _BrandSelectionWidgetState extends State<BrandSelectionWidget> {
  final BrandService _brandService = BrandService();
  List<String> brands = [];

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  Future<void> _loadBrands() async {
    List<String> loadedBrands = await _brandService.getBrands();

    setState(() {
      brands = loadedBrands;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          DropdownButton(
            items: brands
                .map((brand) => DropdownMenuItem(
              value: brand,
              child: Text(brand),
            ))
                .toList(),
            onChanged: (value) {
              // Xử lý khi người dùng chọn thương hiệu
            },
            hint: Text('Chọn thương hiệu'),
          ),
          // Các thành phần giao diện khác
        ],
      ),
    );
  }
}
