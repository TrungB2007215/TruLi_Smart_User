import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> getCategories() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
      await _firestore.collection('categories').get();

      List<String> categories =
      snapshot.docs.map((doc) => doc.get('name') as String).toList();

      return categories;
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  static Future<List<String>> fetchCategoryNames() async {
    QuerySnapshot categorySnapshot = await FirebaseFirestore.instance.collection('categories').get();
    return categorySnapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['name'] as String ?? '')
        .toList();
  }

}
