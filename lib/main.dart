import 'package:user/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:user/my_app_state.dart';
import 'utils/routes.dart';
import 'services/user_service.dart';
import 'services/address_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen/home_screen.dart';
import 'screens/register_screen.dart';
import 'screens/seller/importLogs/import_log_manager_screen.dart';
import 'screens/seller/importLogs/import_log_screen.dart';
import 'screens/seller/importLogs/view_all_log_screen.dart';
import 'screens/seller/importLogs/add_quantity_screen.dart';
import 'screens/seller/importLogs/remove_log_screen.dart';
import 'screens/seller/confirm_order/view_order.dart';
import 'screens/seller/view_review_screen.dart';
import 'screens/seller/revenue_statistics_options_screen.dart';
import 'screens/product/product_manager_screen.dart';
import 'screens/product/add_product_screen.dart';
import 'screens/product/view_all_product_screen.dart';
import 'screens/product/remove_product_screen.dart';
import 'screens/oder/orders_screen.dart';
import 'screens/oder/confirming_screen.dart';
import 'screens/oder/confirmed_screen.dart';
import 'screens/oder/delivered_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // await UserService().addUser('sell', 'sell', '123', 'avatar', 'seller');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final MyAppState appState = MyAppState();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop TruLi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else {
            if (snapshot.hasData) {
              return HomeScreen(isSeller: false, appState: appState);
            } else {
              return LoginScreen(appState: appState);
            }
          }
        },
      ),
      routes: {
        Routes.home: (context) =>
            HomeScreen(isSeller: false, appState: appState),
        Routes.login: (context) => LoginScreen(appState: appState),
        Routes.register: (context) => RegisterScreen(),
        Routes.logManagement: (context) =>
            LogManagerScreen(loggedInUserEmail: appState.loggedInUserEmail),
        Routes.importLogs: (context) =>
            ImportLogScreen(loggedInUserEmail: appState.loggedInUserEmail),
        Routes.viewAllLogs: (context) =>
            ViewAllLogScreen(loggedInUserEmail: appState.loggedInUserEmail),
        Routes.addQuantity: (context) =>
            AddQuantityScreen(loggedInUserEmail: appState.loggedInUserEmail),
        Routes.removeLog: (context) =>
            RemoveLogScreen(loggedInUserEmail: appState.loggedInUserEmail),
        Routes.productManagement: (context) =>
            ProductManagerScreen(loggedInUserEmail: appState.loggedInUserEmail),
        Routes.addProduct: (context) =>
            AddProductScreen(loggedInUserEmail: appState.loggedInUserEmail),
        Routes.viewAllProduct: (context) =>
            ViewAllProductScreen(loggedInUserEmail: appState.loggedInUserEmail),
        Routes.removeProduct: (context) =>
            RemoveProductScreen(loggedInUserEmail: appState.loggedInUserEmail),
        Routes.confirming: (context) =>
            ConfirmingScreen(loggedInUserEmail: appState.loggedInUserEmail),
        Routes.confirmed: (context) =>
            ConfirmedScreen(loggedInUserEmail: appState.loggedInUserEmail),
        Routes.delivered: (context) =>
            DeliveredScreen(loggedInUserEmail: appState.loggedInUserEmail),
        Routes.confirmOrder: (context) =>
            ViewOrder(loggedInUserEmail: appState.loggedInUserEmail),
        Routes.viewRatingsFeedback: (context) =>
            ViewReviewScreen(loggedInUserEmail: appState.loggedInUserEmail),
        Routes.salesStatistics: (context) => RevenueStatisticsOptionsScreen(
            loggedInUserEmail: appState.loggedInUserEmail),
      },
    );
  }
}
