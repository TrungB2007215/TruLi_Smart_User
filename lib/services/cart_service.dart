import 'package:cloud_firestore/cloud_firestore.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> addToCart({
    required String userEmail,
    required String productName,
    required double price,
    required int quantity,
    required String shopOwnerEmail,
  }) async {
    try {
      await _firestore.collection('carts').add({
        'userEmail': userEmail,
        'productName': productName,
        'price': price,
        'quantity': quantity,
        'shopOwnerEmail': shopOwnerEmail,
      });

      // Trả về true nếu ghi nhận được sản phẩm vào giỏ hàng thành công
      return true;
    } catch (e) {
      print('Error adding to cart: $e');

      return false;
    }
  }

  Future<List<DocumentSnapshot>> getUserCartItems(String userEmail) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('carts')
          .where('userEmail', isEqualTo: userEmail)
          .get();

      return querySnapshot.docs;
    } catch (e) {
      print('Error getting user cart items: $e');
      return [];
    }
  }

  Future<void> updateCartItemQuantity(String cartItemId, int newQuantity) async {
    try {
      await _firestore.collection('carts').doc(cartItemId).update({
        'quantity': newQuantity,
      });
    } catch (e) {
      print('Error updating cart item quantity: $e');
      // Xử lý lỗi tại đây nếu cần thiết
    }
  }

  Future<void> deleteCartItem(String cartItemId) async {
    try {
      await _firestore.collection('carts').doc(cartItemId).delete();
    } catch (e) {
      print('Error deleting cart item: $e');
      // Xử lý lỗi tại đây nếu cần thiết
    }
  }

  Future<void> restoreCartItem(String cartItemId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('carts').doc(cartItemId).set(data);
    } catch (e) {
      print('Error restoring cart item: $e');
      // Xử lý lỗi tại đây nếu cần thiết
    }
  }

  Future<bool> checkProductExists(String productName) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('carts')
          .where('productName', isEqualTo: productName)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking product existence: $e');
      return false;
    }
  }


  Future<bool> deleteProductFromCarts(String productName) async {
    try {
      // Tìm kiếm và lấy danh sách các tài liệu chứa sản phẩm có tên productName
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('carts')
          .where('productName', isEqualTo: productName)
          .get();

      // Lặp qua danh sách các tài liệu và xoá chúng khỏi collection "carts"
      querySnapshot.docs.forEach((doc) async {
        await _firestore.collection('carts').doc(doc.id).delete();
      });

      // Trả về true nếu xoá thành công tất cả các sản phẩm có tên productName khỏi collection "carts"
      return true;
    } catch (e) {
      print('Error deleting product from carts: $e');
      // Trả về false nếu có lỗi xảy ra
      return false;
    }
  }

  Future<void> removeSelectedProducts(List<DocumentSnapshot> selectedProducts, String loggedInUserEmail) async {
    try {
      // Duyệt qua từng sản phẩm được chọn
      for (var product in selectedProducts) {
        String productName = product['productName'];

        // Thực hiện truy vấn để lấy tất cả các tài liệu trong giỏ hàng của người dùng có tên sản phẩm và email đăng nhập phù hợp
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('carts')
            .where('userEmail', isEqualTo: loggedInUserEmail)
            .where('productName', isEqualTo: productName)
            .get();

        // Duyệt qua kết quả truy vấn và xóa từng tài liệu một
        for (DocumentSnapshot doc in querySnapshot.docs) {
          await doc.reference.delete();
        }
      }
    } catch (e) {
      // Xử lý lỗi nếu có
      print('Error removing selected products from cart: $e');
      throw e;
    }
  }
}
