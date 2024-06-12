import 'package:flutter/material.dart';
import '../../../services/import_service.dart';
import '../../../utils/routes.dart';

class AddQuantityScreen extends StatefulWidget {
  final String loggedInUserEmail;

  const AddQuantityScreen({Key? key, required this.loggedInUserEmail}) : super(key: key);

  @override
  _AddQuantityScreenState createState() => _AddQuantityScreenState();
}

class _AddQuantityScreenState extends State<AddQuantityScreen> {
  int _quantity = 0; // Số lượng ban đầu là 0
  String? _selectedProductName; // Tên sản phẩm đã chọn

  TextEditingController _quantityController = TextEditingController(); // Controller cho TextField

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm số lượng'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 80),
            _buildDropdownProductName(),
            SizedBox(height: 20),
            Text(
              'Số lượng hiện tại: $_quantity',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Nhập số lượng',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_selectedProductName != null && _quantityController.text.isNotEmpty) {
                  setState(() {
                    _quantity = int.parse(_quantityController.text);
                  });
                  await updateSelectedProductQuantity();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Vui lòng chọn sản phẩm và nhập số lượng.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
              ),
              child: Text('Xác nhận', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loadQuantityFromImportLog() async {
    try {
      if (_selectedProductName != null) {
        int quantityFromLog = await ImportService().getQuantityFromLog(widget.loggedInUserEmail, _selectedProductName!);
        setState(() {
          _quantity = quantityFromLog;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vui lòng chọn sản phẩm.')),
        );
      }
    } catch (e) {
      print('Lỗi khi tải số lượng từ log: $e');
    }
  }

  Future<List<DropdownMenuItem<String>>> getProductNameDropdownItems() async {
    List<DropdownMenuItem<String>> items = [];
    try {
      List<String> productNames = await ImportService().getProductNameWithEmail(widget.loggedInUserEmail);
      items = productNames.map((productName) {
        return DropdownMenuItem(
          value: productName,
          child: Text(productName),
        );
      }).toList();

      await loadQuantityFromImportLog();
    } catch (e) {
      print('Lỗi khi lấy tên sản phẩm: $e');
    }
    return items;
  }

  Widget _buildDropdownProductName() {
    return FutureBuilder<List<DropdownMenuItem<String>>>(
      future: getProductNameDropdownItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Lỗi: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Column(
            children: [
              Text('Bạn chưa nhập hàng không thể thêm sản phẩm!\n'),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, Routes.importLogs);
                },
                child: Text('Nhập hàng ngay nào!!!'),
              ),
            ],
          );
        } else {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButton<String>(
                  value: _selectedProductName,
                  hint: Text('Chọn lô hàng'),
                  onChanged: (String? newValue) async {
                    setState(() {
                      _selectedProductName = newValue ?? '';
                    });
                    await loadQuantityFromImportLog();
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

  Future<void> updateSelectedProductQuantity() async {
    try {
      if (_selectedProductName != null) {
        int logQuantity = await ImportService().getQuantityFromLog(widget.loggedInUserEmail, _selectedProductName!);
        int sumQuantity = logQuantity + int.parse(_quantityController.text);

        await ImportService().updateProductQuantity(widget.loggedInUserEmail, _selectedProductName!, sumQuantity);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bạn nhập hàng thành công.'),
          ),
        );

        await Future.delayed(Duration(seconds: 2));
        Navigator.pop(context);
        setState(() {
          _quantity = sumQuantity;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vui lòng chọn sản phẩm.')),
        );
      }
    } catch (e) {
      print('Lỗi khi cập nhật số lượng sản phẩm: $e');
    }
  }
}
