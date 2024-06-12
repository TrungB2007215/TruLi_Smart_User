import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../utils/routes.dart';
import 'register_screen.dart'; // Import the RegisterScreen if it's not imported yet
import 'home_screen/home_screen.dart';
import 'package:user/my_app_state.dart';

class LoginScreen extends StatefulWidget {
  final MyAppState appState;

  LoginScreen({required this.appState});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        // Check user credentials in Firestore
        // Assume you have a method in FirestoreService to authenticate users
        bool isAuthenticated = await UserService().authenticateUser(email, password);

        if (isAuthenticated) {
          String? role = await UserService().getUserRole(email, password);
          widget.appState.loggedInUserEmail = email; // Set the loggedInUserEmail in the appState

          if (role == 'seller') {
            // Navigate to the home screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(isSeller: true, appState: widget.appState),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(isSeller: false, appState: widget.appState),
              ),
            );
          }
        } else {
          // Login failed, display error message
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Invalid email or password.'),
          ));
        }
      } else {
        // Login failed, display error message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please enter your email and password.'),
        ));
      }
    } catch (e) {
      // Handle login failure
      print('Login failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Login unsuccessful. Please check your email and password.'),
      ));
    }
  }


  void _navigateToRegister() {
    // Navigate to the RegisterScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 30.0),
            Container(
              child: Image.asset(
                'assets/images/logo.png',
                width: 150,
                height: 150,
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  child: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.black,
                  ),
                ),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              obscureText: !_isPasswordVisible,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Center(
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.0),
            TextButton(
              onPressed: _navigateToRegister,
              child: Text.rich(
                TextSpan(
                  text: 'Bạn chưa có tài khoản? ',
                  style: TextStyle(color: Colors.black), // Set the text color to black
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Đăng ký ngay.',
                      style: TextStyle(color: Colors.blue), // Set the text color to blue
                    ),
                  ],
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}
