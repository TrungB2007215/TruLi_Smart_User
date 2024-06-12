import 'package:flutter/material.dart';
import '../../services/technical_specifications_service.dart';
import '../../utils/routes.dart';

class AddTechnicalParametersScreen extends StatefulWidget {
  final String productName;

  AddTechnicalParametersScreen({required this.productName});

  @override
  _AddTechnicalParametersScreenState createState() =>
      _AddTechnicalParametersScreenState();
}

class _AddTechnicalParametersScreenState
    extends State<AddTechnicalParametersScreen> {
  final TextEditingController operatingSystemController = TextEditingController();
  final TextEditingController processorController = TextEditingController();
  final TextEditingController graphicsCardController = TextEditingController();
  final TextEditingController ramController = TextEditingController();
  final TextEditingController romController = TextEditingController();
  final TextEditingController screenSizeController = TextEditingController();
  final TextEditingController cameraController = TextEditingController();
  final TextEditingController batteryCapacityController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm thông số kỹ thuật cho ${widget.productName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: operatingSystemController,
              decoration: InputDecoration(labelText: 'Hệ điều hành'),
            ),
            TextFormField(
              controller: processorController,
              decoration: InputDecoration(labelText: 'Bộ xử lý'),
            ),
            TextFormField(
              controller: graphicsCardController,
              decoration: InputDecoration(labelText: 'Card đồ họa'),
            ),
            TextFormField(
              controller: ramController,
              decoration: InputDecoration(labelText: 'RAM'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: romController,
              decoration: InputDecoration(labelText: 'ROM'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: screenSizeController,
              decoration: InputDecoration(labelText: 'Kích thước màn hình'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: cameraController,
              decoration: InputDecoration(labelText: 'Tần số quét màn hình'),
            ),
            TextFormField(
              controller: batteryCapacityController,
              decoration: InputDecoration(labelText: 'Pin - công suất sạt'),
            ),
            TextFormField(
              controller: weightController,
              decoration: InputDecoration(labelText: 'Trọng lượng'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                saveTechnicalParameters(widget.productName);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
              ),
              child: Text('Lưu thông số kỹ thuật', style: TextStyle(fontSize: 16, color: Colors.black),),
            ),
          ],
        ),
      ),
    );
  }

  void saveTechnicalParameters(String productName) async {
    try {
      await TechnicalSpecificationsService().saveTechnicalParameters(
        productName: productName,
        operatingSystem: operatingSystemController.text,
        processor: processorController.text,
        graphicsCard: graphicsCardController.text,
        ram: int.tryParse(ramController.text) ?? 0,
        rom: int.tryParse(romController.text) ?? 0,
        screenSize: double.tryParse(screenSizeController.text) ?? 0.0,
        camera: cameraController.text,
        batteryCapacity: batteryCapacityController.text,
        weight: double.tryParse(weightController.text) ?? 0.0,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thông số kỹ thuật đã đươc thêm vào sản phẩm.'),
        ),
      );

      // Chuyển hướng sau khi lưu thành công
      Navigator.of(context).pushReplacementNamed(Routes.productManagement);
    } catch (e) {
      print('Lỗi khi lưu thông số kỹ thuật: $e');
    }
  }
}
