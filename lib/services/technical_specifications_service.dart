import 'package:cloud_firestore/cloud_firestore.dart';

class TechnicalSpecificationsService {
  static final TechnicalSpecificationsService _instance =
  TechnicalSpecificationsService._internal();

  factory TechnicalSpecificationsService() {
    return _instance;
  }

  TechnicalSpecificationsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveTechnicalParameters({
    required String productName,
    required String operatingSystem,
    required String processor,
    required String graphicsCard,
    required int ram,
    required int rom,
    required double screenSize,
    required String camera,
    required String batteryCapacity,
    required double weight,
  }) async {
    try {
      await _firestore.collection('technical_specifications').add({
        'productName': productName,
        'operatingSystem': operatingSystem,
        'processor': processor,
        'graphicsCard': graphicsCard,
        'ram': ram,
        'rom': rom,
        'screenSize': screenSize,
        'camera': camera,
        'batteryCapacity': batteryCapacity,
        'weight': weight,
      });
    } catch (e) {
      // Xử lý lỗi nếu có
      print('Lỗi khi lưu thông số kỹ thuật: $e');
      throw Exception('Lưu thông số kỹ thuật thất bại');
    }
  }

  Future<Map<String, dynamic>> getTechnicalSpecifications(String productName) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('technical_specifications')
          .where('productName', isEqualTo: productName)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Chỉ lấy thông số kỹ thuật của sản phẩm đầu tiên trong trường hợp có nhiều sản phẩm cùng tên
        return snapshot.docs.first.data();
      } else {
        // Trả về một Map rỗng nếu không tìm thấy thông số kỹ thuật cho sản phẩm
        return {};
      }
    } catch (e) {
      // Xử lý lỗi nếu có
      print('Lỗi khi lấy thông số kỹ thuật: $e');
      throw Exception('Lấy thông số kỹ thuật thất bại');
    }
  }
}



