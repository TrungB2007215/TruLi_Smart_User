import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/address_service.dart';
import '../../services/info_user_service.dart';

class EditUserInfoPage extends StatefulWidget {
  final String loggedInUserEmail;

  const EditUserInfoPage({Key? key, required this.loggedInUserEmail}) : super(key: key);
  @override
  _EditUserInfoPageState createState() => _EditUserInfoPageState();
}

class _EditUserInfoPageState extends State<EditUserInfoPage> {

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  String selectedProvince = '';
  String selectedDistrict = '';
  String selectedWard = '';


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin nhận hàng'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Tên người nhận',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Số điện thoại',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),

            FutureBuilder<List<DropdownMenuItem<String>>>(
              future: getProvincesDropdownItems(),
              builder: (context, categorySnapshot) {
                if (categorySnapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (categorySnapshot.hasError) {
                  return Text('Error: ${categorySnapshot.error}');
                } else {
                  List<DropdownMenuItem<String>> provinceItems = categorySnapshot.data!;
                  Set<String> uniqueProvince = provinceItems.map((item) => item.value!).toSet();

                  return Container(
                    width: 300,
                    child: DropdownButton<String>(
                      value: selectedProvince.isNotEmpty ? selectedProvince : null,
                      hint: Text('Chọn Tỉnh/Thành Phố'),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedProvince = newValue ?? '';
                          selectedDistrict = ''; // Reset selectedBrand when category changes
                        });
                        // Automatically select the brand containing the selected category
                        setDistrictBasedOnProvince(newValue);
                      },
                      items: provinceItems,
                    ),
                  );
                }
              },
            ),

            SizedBox(height: 10),
            // Dropdown for Districts
            FutureBuilder<List<DropdownMenuItem<String>>>(
              future: getDistrictsDropdownItems(selectedProvince),
              builder: (context, brandSnapshot) {
                if (brandSnapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (brandSnapshot.hasError) {
                  return Text('Error: ${brandSnapshot.error}');
                } else {
                  return Container(
                    width: 300,
                    child: DropdownButton<String>(
                      value: selectedDistrict.isNotEmpty ? selectedDistrict : null,
                      hint: Text('Chọn Quận/Huyện'),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedDistrict = newValue ?? '';
                          selectedWard = '';
                        });
                        setWard(selectedProvince, newValue);
                      },
                      items: brandSnapshot.data!,
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 10),

            FutureBuilder<List<DropdownMenuItem<String>>>(
              future: getWardDropdownItems(selectedProvince, selectedDistrict),
              builder: (context, brandSnapshot) {
                if (brandSnapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (brandSnapshot.hasError) {
                  return Text('Error: ${brandSnapshot.error}');
                } else {
                  return Container(
                    width: 300,
                    child: DropdownButton<String>(
                      value: selectedWard.isNotEmpty ? selectedWard : null,
                      hint: Text('Chọn Phường/Xã'),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedWard = newValue ?? '';
                        });
                      },
                      items: brandSnapshot.data!,
                    ),
                  );
                }
              },
            ),

            SizedBox(height: 20),
            TextField(
              controller: streetController,
              decoration: InputDecoration(
                labelText: 'Địa chỉ',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _handleSaveButtonPressed,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                  ),
                  child: Text('Lưu', style: TextStyle(fontSize: 16, color: Colors.black)),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleSaveButtonPressed() async {
    // Lấy dữ liệu từ các trường nhập liệu
    String name = nameController.text;
    String phone = phoneController.text;
    String street = streetController.text;

    if (selectedProvince.isEmpty || selectedDistrict.isEmpty || selectedWard.isEmpty || street.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Vui lòng chọn đủ thông tin!'),
      ));
      return;
    }

    String addressId = '';
    try {
      DocumentSnapshot<Map<String, dynamic>> addressSnapshot =
      await AddressService().addAddress(
        userEmail: widget.loggedInUserEmail,
        provinceName: selectedProvince,
        districtName: selectedDistrict,
        wardName: selectedWard,
        street: street,
      );
      addressId = addressSnapshot.id;

      // Thêm thông tin người dùng vào Firestore
      await InfoUserService().addInfoUser(
        userEmail: widget.loggedInUserEmail,
        recipientName: name,
        phoneNumber: phone,
        addressId: addressId,
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Lưu thông tin thành công!'),
      ));
    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Lỗi: $e'),
      ));
    }
  }

  void setDistrictBasedOnProvince(String? provinceName) async {
    if (provinceName != null && provinceName.isNotEmpty) {
      List<DropdownMenuItem<String>> districtItems = await getDistrictsDropdownItems(provinceName);
      if (districtItems.isNotEmpty) {
        setState(() {
          selectedDistrict = districtItems[0].value ?? '';
        });
      }
    }
  }

  void setWard(String? provinceName, String? districtName) async {
    if (provinceName != null && provinceName.isNotEmpty && districtName != null && districtName.isNotEmpty) {
      List<DropdownMenuItem<String>> wards = await getWardDropdownItems(provinceName, districtName);
      if (wards.isNotEmpty) {
        setState(() {
          selectedWard = wards[0].value ?? '';
        });
      }
    }
  }

  Future<List<DropdownMenuItem<String>>> getProvincesDropdownItems() async {
    List<DropdownMenuItem<String>> items = [];

    try {
      List<String> provinces = await AddressService().getProvinces();
      provinces.sort();

      items = provinces.map((provinceName) {
        return DropdownMenuItem(
          value: provinceName,
          child: Text(provinceName),
        );
      }).toList();
    } catch (e) {
      print('Error getting provinces: $e');
    }

    return items;
  }

  Future<List<DropdownMenuItem<String>>> getDistrictsDropdownItems(String? provinceName) async {
    List<DropdownMenuItem<String>> items = [];

    if (provinceName != null && provinceName.isNotEmpty) {
      List<String> districts = await AddressService().getDistricts(provinceName);
      districts.sort();

      items = districts.map((districtName) {
        return DropdownMenuItem(
          value: districtName, // Use districtName as the value
          child: Text(districtName),
        );
      }).toList();
    }

    return items;
  }


  Future<List<DropdownMenuItem<String>>> getWardDropdownItems(String provinceName, String districtName) async {
    List<DropdownMenuItem<String>> items = [];

    try {
      // Lấy danh sách xã/phường dựa trên tỉnh/thành phố và huyện/quận đã chọn
      List<String> wards = await AddressService().getWards(provinceName, districtName);
      wards.sort();

      items = wards.map((wardName) {
        return DropdownMenuItem(
          value: wardName,
          child: Text(wardName),
        );
      }).toList();
    } catch (e) {
      print('Error getting wards: $e');
    }

    return items;
  }

}
