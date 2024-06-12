import 'dart:typed_data';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> addProduct({
    required String name,
    required String userEmail,
    required double sellingPrice,
    required String describe,
    required String brandName,
    required String catelogyName,
    required Uint8List images,
  }) async {
    try {
      await _firestore.collection('products').add({
        'name': name,
        'userEmail': userEmail,
        'sellingPrice': sellingPrice,
        'describe': describe,
        'brandName': brandName,
        'catelogyName': catelogyName,
        'images': images,
      });

      // Return true if the product was added successfully
      return true;
    } catch (e) {
      print('Error adding product: $e');
      // Return false if there was an error adding the product
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('products').get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllProductWithEmail(String loggedInUserEmail) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('userEmail', isEqualTo: loggedInUserEmail)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting products by email: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getProductsByOneBrand(String brand) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('brandName', isEqualTo: brand)
          .get();

      List<Map<String, dynamic>> products = snapshot.docs.map((doc) => doc.data()).toList();

      return products;
    } catch (e) {
      print('Error getting products by brand: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getProductsContainingCategory(String category) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('catelogyName', isEqualTo: category)
          .get();

      List<Map<String, dynamic>> products = snapshot.docs.map((doc) => doc.data()).toList();

      return products;
    } catch (e) {
      print('Error getting products by brand: $e');
      return [];
    }
  }




  Future<List<String>> getProductsByBrand(String brand) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('products')
          .where('brandName', isEqualTo: brand)
          .get();

      List<String> products = snapshot.docs.map((doc) => doc.get('name') as String).toList();

      return products;
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }

  static Future<List<String>> fetchProductNames() async {
    QuerySnapshot categorySnapshot = await FirebaseFirestore.instance.collection('products').get();
    return categorySnapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['name'] as String ?? '')
        .toList();
  }

  static Future<List<String>> getProductsByCategory(String category) async {
    List<String> products = [];

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('catelogyName', isEqualTo: category)
          .get();

      querySnapshot.docs.forEach((doc) {
        products.add(doc['name']);
      });
    } catch (e) {
      print('Error getting products: $e');
    }

    return products;
  }

  static Future<double?> getPriceByName(String productName) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('name', isEqualTo: productName)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Convert dynamic to double
        return (snapshot.docs.first.get('sellingPrice') as num?)?.toDouble();
      }

      return null; // Return null if no product found with the given name
    } catch (e) {
      print('Error getting price by name: $e');
      return null;
    }
  }

  static Future<Uint8List?> getImageByName(String productName) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('name', isEqualTo: productName)
          .get();

      if (snapshot.docs.isNotEmpty) {
        dynamic images = snapshot.docs.first.get('images');
        if (images is List<dynamic>) {
          List<int> imageBytes = images.cast<int>();
          return Uint8List.fromList(imageBytes);
        }
      }

      return null; // Return null if no product found with the given name or no image available
    } catch (e) {
      print('Error getting image by name: $e');
      return null;
    }
  }

  Future<bool> deleteProduct(String productName) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('name', isEqualTo: productName)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await FirebaseFirestore.instance.collection('products').doc(snapshot.docs.first.id).delete();
        return true;
      } else {
        return false; // Sản phẩm không tồn tại trong danh sách
      }
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }

  Future<bool> checkProductExists(String productName) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('products')
          .where('name', isEqualTo: productName)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking product existence: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getProductByNameAndShopOwnerEmail({
    required String productName,
    required String shopOwnerEmail,
  }) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('name', isEqualTo: productName)
          .where('userEmail', isEqualTo: shopOwnerEmail)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data();
      } else {
        return null; // Return null if no product found with the given name and shop owner email
      }
    } catch (e) {
      print('Error getting product by name and shop owner email: $e');
      return null;
    }
  }

}
