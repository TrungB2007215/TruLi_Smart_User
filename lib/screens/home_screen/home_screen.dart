import 'package:flutter/material.dart';
import 'package:user/my_app_state.dart';
import '../../utils/routes.dart';
import 'user_home_screen.dart';
import 'shopping_cart_screen.dart';
import 'profile_screen.dart';
import 'search_appbar.dart';
import '../../services/category_service.dart';
import '../../services/brand_service.dart';
import '../../services/product_service.dart';
import 'search_results_page.dart'; // Import SearchResultsPage

class HomeScreen extends StatefulWidget {
  final bool isSeller;
  final MyAppState appState;

  HomeScreen({required this.isSeller, required this.appState});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<String> _categories = [];
  List<String> _allCategories = [];
  List<String> _brands = [];
  List<String> _allBrands = [];
  List<String> _products = [];
  List<String> _allProducts = [];

  late TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    CategoryService.fetchCategoryNames().then((categories) {
      setState(() {
        _allCategories = categories;
      });
    });
    BrandService.fetchBrandNames().then((brands) {
      setState(() {
        _allBrands = brands;
      });
    });
    ProductService.fetchProductNames().then((products) {
      setState(() {
        _allProducts = products;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchAppBar(
        controller: _searchController,
        onSearch: _onSearch,
        turnOffSearchResultsPage:
            turnOffSearchResultsPage, // Truyền hàm callback vào SearchAppBar
      ),
      body: _categories.isEmpty && _brands.isEmpty && _products.isEmpty
          ? _getBody(_currentIndex) // Show main content if no search results
          : SearchResultsPage(
              categories: _categories,
              brands: _brands,
              products: _products,
              loggedInUserEmail: widget.appState.loggedInUserEmail,
            ), // Show search results if available
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Shopping Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          if (widget.isSeller)
            BottomNavigationBarItem(
              icon: Icon(Icons.business),
              label: 'Seller Item',
            ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  void _onSearch(String searchQuery) async {
    if (searchQuery.isEmpty) {
      setState(() {
        _categories = _allCategories;
        _brands = _allBrands;
        _products = _allProducts;
      });
    } else {
      List<String> filteredCategories =
          (await CategoryService.fetchCategoryNames())
              .where((category) =>
                  category.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();

      List<String> filteredBrands = (await BrandService.fetchBrandNames())
          .where((brand) =>
              brand.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();

      List<String> filteredProducts = (await ProductService.fetchProductNames())
          .where((product) =>
              product.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();

      setState(() {
        _categories = filteredCategories;
        _brands = filteredBrands;
        _products = filteredProducts;
      });
    }
  }

  Widget _getBody(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return UserHomeScreen(widget.appState.loggedInUserEmail);
      case 1:
        return ShoppingCartScreen(widget.appState.loggedInUserEmail);
      case 2:
        return ProfileScreen(
            loggedInUserEmail: widget.appState.loggedInUserEmail);
      case 3:
        return widget.isSeller ? _buildSellerHomeScreen() : Container();
      default:
        return Container();
    }
  }

  Widget _buildSellerHomeScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                Routes.logManagement,
                arguments: widget.appState.loggedInUserEmail,
              );
            },
            icon: Icon(Icons.shopping_cart, size: 40),
            label: Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: Text(
                'Quản lý nhập hàng',
                style: TextStyle(fontSize: 20),
              ),
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.purple,
              onPrimary: Colors.white,
              padding: EdgeInsets.all(18),
            ),
          ),
          SizedBox(height: 20),
          // Product Management
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, Routes.productManagement);
                },
                icon: Icon(Icons.shopping_basket, size: 40),
                label: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: Text(
                    'Quản lý sản phẩm',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  onPrimary: Colors.white,
                  padding: EdgeInsets.all(18),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
          SizedBox(height: 20),
          // View Ratings and Feedback
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, Routes.viewRatingsFeedback);
            },
            icon: Icon(Icons.star, size: 40),
            label: Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: Text(
                'Xem đánh giá',
                style: TextStyle(fontSize: 20),
              ),
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.yellow,
              onPrimary: Colors.white,
              padding: EdgeInsets.all(18),
            ),
          ),
          SizedBox(height: 20),
          // Sales Statistics
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, Routes.salesStatistics);
            },
            icon: Icon(Icons.bar_chart, size: 40),
            label: Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: Text(
                'Thống kê doanh thu',
                style: TextStyle(fontSize: 20),
              ),
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.teal,
              onPrimary: Colors.white,
              padding: EdgeInsets.all(18),
            ),
          ),
          SizedBox(height: 20),
          // Confirm Order
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                Routes.confirmOrder,
                arguments: widget.appState.loggedInUserEmail,
              );
            },
            icon: Icon(Icons.check_circle, size: 40),
            label: Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: Text(
                'Xác nhận đơn hàng',
                style: TextStyle(fontSize: 20),
              ),
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.cyan,
              onPrimary: Colors.white,
              padding: EdgeInsets.all(18),
            ),
          ),
        ],
      ),
    );
  }

  // Phương thức để tắt SearchResultsPage
  void turnOffSearchResultsPage() {
    setState(() {
      _categories.clear();
      _brands.clear();
      _products.clear();
    });
  }
}
