import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reviews_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveReview(Review review) async {
    try {
      await _firestore.collection('reviews').add({
        'rating': review.rating,
        'comment': review.comment,
        'userEmail': review.userEmail,
        'productName': review.productName,
        'shopOwnerEmail': review.shopOwnerEmail,
        'timestamp': review.timestamp,
      });
    } catch (e) {
      throw Exception('Error saving review: $e');
    }
  }

  Future<List<Review>> getReviewsByUserAndProduct({required String userEmail, required String productName}) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('reviews')
          .where('userEmail', isEqualTo: userEmail) // Lọc theo email người dùng
          .where('productName', isEqualTo: productName) // Lọc theo tên sản phẩm
          .get();

      List<Review> reviews = []; // Danh sách lưu trữ các đánh giá

      querySnapshot.docs.forEach((doc) {
        // Đọc dữ liệu từ Firestore và chuyển đổi thành đối tượng Review
        Review review = Review(
          rating: doc['rating'],
          comment: doc['comment'],
          userEmail: doc['userEmail'],
          productName: doc['productName'],
          shopOwnerEmail: doc['shopOwnerEmail'],
          timestamp: doc['timestamp'] != null ? doc['timestamp'].toDate() : null,
        );

        reviews.add(review); // Thêm đánh giá vào danh sách
      });

      return reviews; // Trả về danh sách các đánh giá
    } catch (e) {
      print('Error getting reviews by user and product: $e');
      return []; // Trả về danh sách rỗng nếu có lỗi xảy ra
    }
  }

  Future<List<Review>> getReviewsByShopOwner({required String userEmail}) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('reviews')
          .where('userEmail', isEqualTo: userEmail) // Lọc theo email người dùng
          .get();

      List<Review> reviews = []; // Danh sách lưu trữ các đánh giá

      querySnapshot.docs.forEach((doc) {
        // Đọc dữ liệu từ Firestore và chuyển đổi thành đối tượng Review
        Review review = Review(
          rating: doc['rating'],
          comment: doc['comment'],
          userEmail: doc['userEmail'],
          productName: doc['productName'],
          shopOwnerEmail: doc['shopOwnerEmail'],
          timestamp: doc['timestamp'] != null ? doc['timestamp'].toDate() : null,
        );

        reviews.add(review); // Thêm đánh giá vào danh sách
      });

      return reviews; // Trả về danh sách các đánh giá
    } catch (e) {
      print('Error getting reviews by user and product: $e');
      return []; // Trả về danh sách rỗng nếu có lỗi xảy ra
    }
  }

  Future<List<Review>> getReviewsByProductName(String productName) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('reviews')
          .where('productName', isEqualTo: productName) // Lọc theo tên sản phẩm
          .get();

      List<Review> reviews = []; // Danh sách lưu trữ các đánh giá

      querySnapshot.docs.forEach((doc) {
        // Đọc dữ liệu từ Firestore và chuyển đổi thành đối tượng Review
        Review review = Review(
          rating: doc['rating'],
          comment: doc['comment'],
          userEmail: doc['userEmail'],
          productName: doc['productName'],
          shopOwnerEmail: doc['shopOwnerEmail'],
          timestamp: doc['timestamp'] != null ? doc['timestamp'].toDate() : null,
        );

        reviews.add(review); // Thêm đánh giá vào danh sách
      });

      return reviews; // Trả về danh sách các đánh giá
    } catch (e) {
      print('Error getting reviews by product name: $e');
      return []; // Trả về danh sách rỗng nếu có lỗi xảy ra
    }
  }
}