import 'package:flutter/material.dart';
import '../../../services/import_service.dart';
import '../../../services/user_service.dart';
import '../../../services/category_service.dart';
import '../../../services/brand_service.dart';
import 'add_quantity_screen.dart';

class ImportLogScreen extends StatefulWidget {
  final String loggedInUserEmail;

  const ImportLogScreen({Key? key, required this.loggedInUserEmail})
      : super(key: key);

  @override
  _ImportLogScreenState createState() => _ImportLogScreenState();
}

class _ImportLogScreenState extends State<ImportLogScreen> {
  final ImportService importService = ImportService();
  final UserService userService = UserService();
  final TextEditingController productNameController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  final TextEditingController importDateController = TextEditingController();
  final TextEditingController importPriceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  String selectedCategory = '';
  String selectedBrand = '';

  @override
  void initState() {
    super.initState();
    importDateController.text = formatDate(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    print('Logged In User Email: ${widget.loggedInUserEmail}');

    return Scaffold(
      appBar: AppBar(
        title: Text('Nhập hàng'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Dropdown for Categories
              FutureBuilder<List<DropdownMenuItem<String>>>(
                future: getCategoryDropdownItems(),
                builder: (context, categorySnapshot) {
                  if (categorySnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (categorySnapshot.hasError) {
                    return Text('Error: ${categorySnapshot.error}');
                  } else {
                    List<DropdownMenuItem<String>> categoryItems =
                        categorySnapshot.data!;
                    Set<String> uniqueCategories =
                        categoryItems.map((item) => item.value!).toSet();

                    return Container(
                      width: 300,
                      child: DropdownButton<String>(
                        value: selectedCategory.isNotEmpty
                            ? selectedCategory
                            : null,
                        hint: Text('Chọn danh mục'),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCategory = newValue ?? '';
                            selectedBrand =
                                ''; // Reset selectedBrand when category changes
                          });
                          // Automatically select the brand containing the selected category
                          setBrandBasedOnCategory(newValue);
                        },
                        items: categoryItems,
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: 10),
              // Dropdown for Brands
              FutureBuilder<List<DropdownMenuItem<String>>>(
                future: getBrandDropdownItems(selectedCategory),
                builder: (context, brandSnapshot) {
                  if (brandSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (brandSnapshot.hasError) {
                    return Text('Error: ${brandSnapshot.error}');
                  } else {
                    return Container(
                      width: 300,
                      child: DropdownButton<String>(
                        value: selectedBrand.isNotEmpty ? selectedBrand : null,
                        hint: Text('Chọn thương hiệu'),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedBrand = newValue ?? '';
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
                controller: productNameController,
                decoration: InputDecoration(
                  labelText: 'Tên sản phẩm nhập',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              FutureBuilder(
                future: userService.getUserInfo(widget.loggedInUserEmail),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    String userName = snapshot.data.toString();
                    return Text(
                      'Người nhập hàng: $userName',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    );
                  }
                },
              ),
              SizedBox(height: 10),
              InkWell(
                onTap: () {
                  _selectDate(context);
                },
                child: IgnorePointer(
                  child: TextField(
                    controller: importDateController,
                    decoration: InputDecoration(
                      labelText: 'Ngày nhập',
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: importPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Giá nhập',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Số lượng',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  saveImport();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                ),
                child: Text(
                  'Nhập hàng',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        importDateController.text = formatDate(selectedDate!);
      });
    }
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void setBrandBasedOnCategory(String? category) async {
    if (category != null && category.isNotEmpty) {
      List<DropdownMenuItem<String>> brandItems =
          await getBrandDropdownItems(category);
      if (brandItems.isNotEmpty) {
        setState(() {
          selectedBrand = brandItems[0].value ?? '';
        });
      }
    }
  }

  void saveImport() async {
    final userEmail = widget.loggedInUserEmail;
    String productName = productNameController.text;
    final importLog = ImportLog(
      category: selectedCategory,
      brand: selectedBrand,
      productName: productName,
      userEmail: userEmail,
      importDate: selectedDate,
      importPrice: double.parse(importPriceController.text),
      quantity: int.parse(quantityController.text),
    );

    bool exists = await importService.doesProductNameExist(productName);
    if (exists) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Lô hàng đã tồn tại'),
            content: Text(
                'Lô hàng của bạn đã có. Bạn có muốn đến trang thêm số lượng cho lô hàng này không?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  navigateToAddQuantityScreen();
                },
                child: Text('Đồng ý'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Hủy bỏ'),
              ),
            ],
          );
        },
      );
    } else {
      bool success = await importService.addImportLog(
        category: importLog.category,
        brand: importLog.brand,
        productName: importLog.productName,
        userEmail: importLog.userEmail ?? '',
        importDate: importLog.importDate,
        importPrice: importLog.importPrice,
        quantity: importLog.quantity,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bạn nhập hàng thành công.'),
          ),
        );

        await Future.delayed(Duration(seconds: 2));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bạn nhập hàng thất bại.'),
          ),
        );
      }

      print('Danh mục: ${importLog.category}');
      print('Thương hiệu: ${importLog.brand}');
      print('Tên sản phẩm nhập: ${importLog.productName}');
      print('Người nhập hàng (Email): ${importLog.userEmail ?? 'Not specified'}');
      print('Ngày nhập: ${importLog.importDate}');
      print('Giá nhập: ${importLog.importPrice}');
      print('Số lượng: ${importLog.quantity}');
    }
  }

  void navigateToAddQuantityScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddQuantityScreen(loggedInUserEmail: widget.loggedInUserEmail),
      ),
    );
  }

  Future<List<DropdownMenuItem<String>>> getCategoryDropdownItems() async {
    List<DropdownMenuItem<String>> items = [];

    try {
      List<String> categories = await CategoryService().getCategories();

      items = categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList();
    } catch (e) {
      print('Error getting categories: $e');
    }

    return items;
  }

  Future<List<DropdownMenuItem<String>>> getBrandDropdownItems(
      String category) async {
    List<DropdownMenuItem<String>> items = [];

    try {
      List<String> brands =
          await BrandService().getBrandsContainingCategory(category);

      items = brands.map((brand) {
        return DropdownMenuItem(
          value: brand,
          child: Text(brand),
        );
      }).toList();
    } catch (e) {
      print('Error getting brands: $e');
    }

    return items;
  }
}

class ImportLog {
  final String category;
  final String brand;
  final String productName;
  final String? userEmail;
  final DateTime importDate;
  final double importPrice;
  final int quantity;

  ImportLog({
    required this.category,
    required this.brand,
    required this.productName,
    required this.userEmail,
    required this.importDate,
    required this.importPrice,
    required this.quantity,
  });
}
