import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/import_service.dart';

class ViewAllLogScreen extends StatefulWidget {
  final String loggedInUserEmail;

  const ViewAllLogScreen({Key? key, required this.loggedInUserEmail}) : super(key: key);

  @override
  _ViewAllLogScreenState createState() => _ViewAllLogScreenState();
}

class _ViewAllLogScreenState extends State<ViewAllLogScreen> {
  final ImportService importService = ImportService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách nhập hàng'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: importService.getImportLogWithEmail(widget.loggedInUserEmail),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> log = snapshot.data![index];
                return ListTile(
                  title: Text(log['productName']),
                  subtitle: FutureBuilder<int>(
                    future: importService.getTotalQuantityInStock(log['productName']),
                    builder: (context, quantitySnapshot) {
                      if (quantitySnapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (quantitySnapshot.hasError) {
                        return Text('Error: ${quantitySnapshot.error}');
                      }
                      if (quantitySnapshot.hasData) {
                        int totalQuantity = quantitySnapshot.data!;
                        return Text('Kho: $totalQuantity');
                      }
                      return Text('Unknown');
                    },
                  ),
                );
              },
            );
          }
          return Center(
            child: Text('Không có dữ liệu nhập hàng.'),
          );
        },
      ),
    );
  }
}
