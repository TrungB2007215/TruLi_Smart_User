import 'package:cloud_firestore/cloud_firestore.dart';

class BrandService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> getBrands() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
      await _firestore.collection('brands').get();

      List<String> brands =
      snapshot.docs.map((doc) => doc.get('name') as String).toList();

      return brands;
    } catch (e) {
      print('Error getting brands: $e');
      return [];
    }
  }

  static Future<List<String>> fetchBrandNames() async {
    QuerySnapshot categorySnapshot = await FirebaseFirestore.instance.collection('brands').get();
    return categorySnapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['name'] as String ?? '')
        .toList();
  }

  static Future<List<String>> getBrandsContainingCategories(String category) async {
    List<String> brandsContainingCategory = [];

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('brands')
          .where('category', isEqualTo: category) // So sánh trực tiếp với giá trị category
          .get();

      querySnapshot.docs.forEach((doc) {
        brandsContainingCategory.add(doc['name']);
      });
    } catch (e) {
      print('Error getting brands: $e');
    }

    return brandsContainingCategory;
  }

  Future<List<String>> getBrandsContainingCategory(String category) async {
    List<String> brandsContainingCategory = [];

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('brands')
          .where('category', isEqualTo: category) // So sánh trực tiếp với giá trị category
          .get();

      querySnapshot.docs.forEach((doc) {
        brandsContainingCategory.add(doc['name']);
      });
    } catch (e) {
      print('Error getting brands: $e');
    }

    return brandsContainingCategory;
  }



}