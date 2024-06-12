import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/product_service.dart';
import '../../services/category_service.dart';
import '../../services/brand_service.dart';
import '../../services/import_service.dart';
import 'add_technicalParameters_screen.dart';
import '../../utils/routes.dart';

class AddProductScreen extends StatefulWidget {
  final String loggedInUserEmail;
  const AddProductScreen({Key? key, required this.loggedInUserEmail})
      : super(key: key);
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  String name = "";
  double sellingPrice = 0.0;
  String describe = "";
  String brandName = "";
  String catelogyName = "";
  final ProductService productService = ProductService();
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController describeController = TextEditingController();
  Uint8List? _imageData;

  @override
  void initState() {
    super.initState();
    // Gọi hàm _loadBrandAndCategory từ initState để cập nhật giá trị brandName và catelogyName khi StatefulWidget được khởi tạo
    _loadBrandAndCategory(name);
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        File imageFile = File(pickedFile.path);
        Uint8List imageData = await imageFile.readAsBytes();

        setState(() {
          _imageData = imageData;
        });
      } catch (e) {
        print("Error loading image: $e");
      }
    }
  }

  Future<List<DropdownMenuItem<String>>> getProductNameDropdownItems() async {
    List<DropdownMenuItem<String>> items = [];
    try {
      List<String> productNames = await ImportService()
          .getProductNameWithEmail(widget.loggedInUserEmail);

      items = productNames.map((productName) {
        return DropdownMenuItem(
          value: productName,
          child: Text(productName),
        );
      }).toList();
    } catch (e) {
      print('Error getting product names: $e');
    }

    return items;
  }

  Future<void> _loadBrandAndCategory(String productName) async {
    print("Error loading image");
    try {
      print("Alo");
      Map<String, dynamic>? productInfo =
          await ImportService().getProductInfoWithName(productName);
      if (productInfo != null) {
        setState(() {
          print('productInfo');
          print(productInfo);
          if (productInfo.containsKey('brand')) {
            brandName = productInfo['brand'];
          } else {
            print('Không tồn tại thông tin về thương hiệu');
          }
          if (productInfo.containsKey('category')) {
            catelogyName = productInfo['category'];
          } else {
            print('Không tồn tại thông tin về danh mục');
          }
        });
      }
      print("lỗi if");
    } catch (e) {
      print('Error loading brand and category: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm sản phẩm'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildDropdownProductName(),
              SizedBox(height: 16),
              _buildTextField(priceController, 'Giá bán', TextInputType.number),
              _buildTextField(describeController, 'Mô tả'),
              SizedBox(height: 16),
              _buildBrandAndCategoryInfo(),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  await _getImage();
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(),
                    shape: BoxShape.circle,
                  ),
                  child: _imageData != null
                      ? ClipOval(
                          child: Image.memory(
                            _imageData!,
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                          ),
                        )
                      : Center(
                          child: Icon(Icons.camera_alt, size: 50),
                        ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await _addProduct(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                ),
                child: Text(
                  'Thêm sản phẩm',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      [TextInputType inputType = TextInputType.text]) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
        ),
        keyboardType: inputType,
        onChanged: (value) {
          setState(() {
            if (controller == nameController) {
              name = value;
            } else if (controller == priceController) {
              sellingPrice = double.parse(value);
            } else if (controller == describeController) {
              describe = value;
            }
          });
        },
      ),
    );
  }

  Widget _buildDropdownProductName() {
    return FutureBuilder<List<DropdownMenuItem<String>>>(
      future: getProductNameDropdownItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Column(
            children: [
              Text('Bạn chưa nhập hàng không thể thêm sản phẩm!\n'),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, Routes.importLogs);
                },
                child: Text('Nhập hàng ngay nào!!!'),
              ),
            ],
          );
        } else {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tên sản phẩm'),
                DropdownButton<String>(
                  value: name.isEmpty ? null : name,
                  onChanged: (String? newValue) {
                    setState(() {
                      name = newValue ?? '';
                      brandName = '';
                      catelogyName = '';
                    });
                    _loadBrandAndCategory(newValue ?? '');
                  },
                  items: snapshot.data!,
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildBrandAndCategoryInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Thương hiệu: $brandName'),
        Text('Danh mục: $catelogyName'),
      ],
    );
  }

  Future<void> _addProduct(BuildContext context) async {
    Uint8List nonNullableImageData = _imageData ?? Uint8List(0);
    if (sellingPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Giá bán không hợp lệ. Vui lòng nhập lại.'),
        ),
      );
      return;
    } else {
      bool success = await productService.addProduct(
        name: name,
        userEmail: widget.loggedInUserEmail,
        sellingPrice: sellingPrice,
        describe: describe,
        brandName: brandName,
        catelogyName: catelogyName,
        images: nonNullableImageData,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sản phẩm đã được thêm thành công.'),
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AddTechnicalParametersScreen(productName: name),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi thêm sản phẩm.'),
          ),
        );
      }

      print('Danh mục: $catelogyName');
      print('Thương hiệu: $brandName');
      print('Tên sản phẩm nhập: $name');
      print('Mô tả: $describe ');
      print('Giá bán: $sellingPrice');
      print('Ảnh: $nonNullableImageData');
    }
  }
}
