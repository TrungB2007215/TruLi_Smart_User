import 'package:flutter/material.dart';
import '../../models/brand_model.dart'; // Import Brand model

class BrandList extends StatelessWidget {
  final List<String> brands;

  const BrandList({Key? key, required this.brands}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: brands.map((brand) => Text(brand)).toList(),
    );
  }
}
