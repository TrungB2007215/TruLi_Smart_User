import 'package:cloud_firestore/cloud_firestore.dart';

class ImportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> addImportLog({
    required category,
    required brand,
    required String productName,
    required String userEmail,
    required DateTime importDate,
    required double importPrice,
    required int quantity,
  }) async {
    try {
      await _firestore.collection('importLog').add({
        'category': category,
        'brand': brand,
        'productName': productName,
        'userEmail': userEmail,
        'importDate': importDate,
        'importPrice': importPrice,
        'quantity': quantity,
      });
      return true;
    } catch (e) {
      print('Error adding import log: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getImportLogs() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('importLog').get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting import logs: $e');
      return [];
    }
  }

  Future<bool> doesProductNameExist(String productName) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('importLog')
          .where('productName', isEqualTo: productName)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking product name existence: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getImportLogWithEmail(
      String loggedInUserEmail) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('importLog')
          .where('userEmail', isEqualTo: loggedInUserEmail)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting import logs: $e');
      return [];
    }
  }

  Future<bool> removeImportLog(String productName) async {
    try {
      await _firestore
          .collection('importLog')
          .where('productName', isEqualTo: productName)
          .get()
          .then((snapshot) {
        snapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });
      print('Import log removed successfully');
      return true;
    } catch (e) {
      print('Error removing import log: $e');
      return false;
    }
  }

  Future<List<String>> getProductNameWithEmail(String loggedInUserEmail) async {
    try {
      QuerySnapshot<Map<String, dynamic>> importLogsSnapshot =
          await FirebaseFirestore.instance
              .collection('importLog')
              .where('userEmail', isEqualTo: loggedInUserEmail)
              .get();

      List<String> productNames = [];

      importLogsSnapshot.docs.forEach((doc) {
        var productName = doc.data()['productName'] as String;
        if (productName != null && productName.isNotEmpty) {
          productNames.add(productName);
        }
      });

      return productNames;
    } catch (e) {
      print('Lỗi khi lấy danh sách tên sản phẩm: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getProductInfoWithName(
      String productName) async {
    try {
      QuerySnapshot<Map<String, dynamic>> importLogsSnapshot = await _firestore
          .collection('importLog')
          .where('productName', isEqualTo: productName)
          .get();

      if (importLogsSnapshot.docs.isNotEmpty) {
        return importLogsSnapshot.docs.first.data();
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting product info: $e');
      return null;
    }
  }

  Future<int> getTotalQuantityInStock(String productName) async {
    try {
      QuerySnapshot<Map<String, dynamic>> importLogsSnapshot = await _firestore
          .collection('importLog')
          .where('productName', isEqualTo: productName)
          .get();

      // Tính tổng số lượng của sản phẩm với tên được chỉ định
      int totalQuantity = 0;
      importLogsSnapshot.docs.forEach((doc) {
        var quantity = doc.data()['quantity'] as int?;
        if (quantity != null) {
          totalQuantity += quantity;
        }
      });

      return totalQuantity;
    } catch (e) {
      print('Error getting total quantity in stock: $e');
      // Trả về 0 nếu có lỗi xảy ra
      return 0;
    }
  }

  Future<String> getShopOwnerEmail(String productName) async {
    try {
      QuerySnapshot<Map<String, dynamic>> importLogsSnapshot = await _firestore
          .collection('importLog')
          .where('productName', isEqualTo: productName)
          .get();

      if (importLogsSnapshot.docs.isNotEmpty) {
        var shopOwnerEmail = importLogsSnapshot.docs.first.data()['userEmail'];
        if (shopOwnerEmail != null && shopOwnerEmail is String) {
          return shopOwnerEmail;
        } else {
          throw 'Invalid shop owner email';
        }
      } else {
        throw 'No import log found for product: $productName';
      }
    } catch (e) {
      print('Error getting shop owner email: $e');

      return '';
    }
  }

  Future<int> getQuantityFromLog(String userEmail, String productName) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('importLog')
          .where('userEmail', isEqualTo: userEmail)
          .where('productName', isEqualTo: productName)
          .get();

      int quantity = 0;
      snapshot.docs.forEach((doc) {
        var docData = doc.data();
        if (docData.containsKey('quantity')) {
          quantity += docData['quantity'] as int;
        }
      });

      return quantity;
    } catch (e) {
      print('Error getting quantity from log: $e');
      return 0;
    }
  }

  Future<void> updateProductQuantity(
      String loggedInUserEmail, String productName, int newQuantity) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('importLog')
          .where('userEmail', isEqualTo: loggedInUserEmail)
          .where('productName', isEqualTo: productName)
          .get();

      if (snapshot.docs.isNotEmpty) {
        snapshot.docs.forEach((doc) async {
          var docRef = doc.reference;
          var currentQuantity = doc.data()['quantity'] as int?;
          if (currentQuantity != null) {
            await docRef.update({'quantity': newQuantity});
          }
        });
      } else {
        print('No import log found for product: $productName');
      }
    } catch (e) {
      print('Error updating product quantity: $e');
    }
  }

  Future<void> updateImportLogQuantity(
      String productName, String shopOwnerEmail, int newQuantity) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('importLog')
          .where('userEmail', isEqualTo: shopOwnerEmail)
          .where('productName', isEqualTo: productName)
          .get();

      if (snapshot.docs.isNotEmpty) {
        snapshot.docs.forEach((doc) async {
          var docRef = doc.reference;
          var currentQuantity = doc.data()['quantity'] as int?;
          if (currentQuantity != null) {
            var updatedQuantity = (currentQuantity - newQuantity);
            await docRef.update({'quantity': updatedQuantity});
            print('Updated quantity for $productName: $updatedQuantity');
          }
        });
      } else {
        print('No import log found for product: $productName');
      }
    } catch (e) {
      print('Error updating product quantity: $e');
    }
  }
}
