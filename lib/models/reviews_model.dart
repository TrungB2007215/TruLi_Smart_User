import 'package:flutter/foundation.dart'; // Import this for @required annotation

class Review {
  final int rating;
  final String comment;
  final String userEmail;
  final String productName;
  final String shopOwnerEmail;
  final DateTime timestamp;

  Review({
    required this.rating,
    required this.comment,
    required this.userEmail,
    required this.productName,
    required this.shopOwnerEmail,
    required this.timestamp,
  });
}
