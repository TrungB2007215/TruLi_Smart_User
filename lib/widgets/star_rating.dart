import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;

  StarRating({required this.rating, this.size = 24.0, this.color = Colors.amber});

  @override
  Widget build(BuildContext context) {
    int numberOfStars = rating.round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < numberOfStars) {
          return Icon(
            Icons.star,
            size: size,
            color: color,
          );
        } else {
          return Icon(
            Icons.star_border,
            size: size,
            color: color,
          );
        }
      }),
    );
  }
}
