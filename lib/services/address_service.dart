import 'package:cloud_firestore/cloud_firestore.dart';

class AddressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addProvince({
    required String provinceName,
  }) async {
    try {
      await _firestore.collection('provinces').add({
        'provinceName': provinceName,
      });
    } catch (e) {
      print('Error adding province: $e');
      throw e;
    }
  }

  Future<List<String>> getProvinces() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('provinces').get();
      List<String> provinces = querySnapshot.docs.map((doc) => doc.get('provinceName') as String).toList();
      return provinces;
    } catch (e) {
      print('Error getting provinces: $e');
      throw e;
    }
  }

  Future<void> addDistrict({
    required String provinceName,
    required String districtName,
  }) async {
    try {
      await _firestore.collection('districts').add({
        'provinceName': provinceName,
        'districtName': districtName,
      });
    } catch (e) {
      print('Error adding district: $e');
      throw e;
    }
  }

  Future<List<String>> getDistricts(String provinceName) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('districts')
          .where('provinceName', isEqualTo: provinceName)
          .get();
      List<String> provinces = querySnapshot.docs.map((doc) => doc.get('districtName') as String).toList();
      return provinces;
    } catch (e) {
      print('Error getting provinces: $e');
      throw e;
    }
  }

  Future<void> addWard({
    required String provinceName,
    required String districtName,
    required String wardName,
  }) async {
    try {
      await _firestore.collection('wards').add({
        'provinceName': provinceName,
        'districtName': districtName,
        'wardName': wardName,
      });
    } catch (e) {
      print('Error adding ward: $e');
      throw e;
    }
  }

  Future<List<String>> getWards(String provinceName, String districtName) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('wards')
          .where('provinceName', isEqualTo: provinceName)
          .where('districtName', isEqualTo: districtName)
          .get();
      List<String> provinces = querySnapshot.docs.map((doc) => doc.get('wardName') as String).toList();
      return provinces;
    } catch (e) {
      print('Error getting provinces: $e');
      throw e;
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> addAddress({
    required String userEmail,
    required String provinceName,
    required String districtName,
    required String wardName,
    required String street,
  }) async {

    Map<String, dynamic> address = {
      'userEmail': userEmail,
      'province': provinceName,
      'district': districtName,
      'ward': wardName,
      'street': street,
    };

    CollectionReference<Map<String, dynamic>> addressesCollection = FirebaseFirestore.instance.collection('addresses');
    DocumentReference<Map<String, dynamic>> addressRef = await addressesCollection.add(address);

    DocumentSnapshot<Map<String, dynamic>> addressSnapshot = await addressRef.get();

    return addressSnapshot;
  }

  Future<Map<String, dynamic>?> getAddressById(String addressId) async {
    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('addresses')
          .doc(addressId)
          .get();
      if (documentSnapshot.exists) {
        print('Có data addresses');
        return documentSnapshot.data() as Map<String, dynamic>;
      } else {
        print('Không có data addresses');
        return null; // Trả về null nếu không tìm thấy dữ liệu
      }
    } catch (e) {
      print('Error getting address: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>?> getAddressUserEmail(String userEmail) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('addresses')
          .where('userEmail', isEqualTo: userEmail)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        print('Có data addresses');
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

