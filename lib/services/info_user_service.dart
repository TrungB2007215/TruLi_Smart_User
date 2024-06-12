import 'package:cloud_firestore/cloud_firestore.dart';

class InfoUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addInfoUser({
    required String userEmail,
    required String recipientName,
    required String phoneNumber,
    required String addressId,
  }) async {
    try {
      await _firestore.collection('info_users').add({
        'userEmail': userEmail,
        'recipientName': recipientName,
        'phoneNumber': phoneNumber,
        'address': addressId,
      });
    } catch (e) {

      print('Error adding address: $e');
      throw e; // Re-throw lỗi để cho phép mã gọi phương thức này xử lý lỗi
    }
  }

  Future<Map<String, dynamic>?> getInfoUserByUserEmail(String userEmail) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('info_users')
          .where('userEmail', isEqualTo: userEmail)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        print('Có data info_users');
        return querySnapshot.docs.first.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting info user: $e');
      throw e;
    }
  }

}

