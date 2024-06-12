import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addUser(String userName, String email, String password, String avatar, String role) async {
    try {
      await _firestore.collection('Users').add({
        'userName': userName,
        'email': email,
        'avatar': avatar,
        'role': role,
        'password': password,
      });
    } catch (e) {
      print('Error adding user: $e');
    }
  }

  Future<bool> authenticateUser(String email, String password) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('Users')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error authenticating user: $e');
      return false;
    }
  }

  Future<String?> getUserRole(String email, String password) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('Users')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Assuming there is only one document, retrieve the role
        return snapshot.docs[0]['role'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }

  Future<String?> getRole(String email) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('Users')
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs[0]['role'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }

  Future<String?> getUserInfo(String email) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('Users')
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Assuming there is only one document, retrieve the role
        return snapshot.docs[0]['userName'] as String?;
      } else {
        return 'User not found';
      }
    } catch (e) {
      print('Error fetching username: $e');
      return null;
    }
  }
  // Future<String> getUserInfo(String userEmail) async {
  //   try {
  //     QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
  //         .collection('users')
  //         .where('email', isEqualTo: userEmail)
  //         .get();
  //
  //     if (snapshot.docs.isNotEmpty) {
  //       return snapshot.docs.first['userName'].toString(); // Replace 'userName' with the actual field name in your Firestore document
  //     } else {
  //       return 'User not found';
  //     }
  //   } catch (e) {
  //     print('Error fetching user info: $e');
  //     return 'Error fetching user info';
  //   }
  // }

  Future<bool> checkEmailExists(String email) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('Users')
          .where('email', isEqualTo: email)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking email existence: $e');
      return false;
    }
  }

  Future<bool> checkUsernameExists(String userName) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('Users')
          .where('userName', isEqualTo: userName)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking username existence: $e');
      return false;
    }
  }

  Future<bool> updateUserRole(String email, String newRole) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot<Map<String, dynamic>> userSnapshot = snapshot.docs.first;

        DocumentReference userRef = userSnapshot.reference;
        await userRef.update({'role': newRole});
        return true;
      } else {
        print('Tài khoản không tồn tại');
        return false;
      }
    } catch (e) {
      print('Lỗi khi cập nhật vai trò người dùng: $e');
      return false;
    }
  }
}
