import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firstproject/screens/login_screen.dart';
// **** THIS IS THE LINE YOU NEED TO ADD ****
import 'package:firstproject/screens/home_screen.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('refreshToken');

  runApp(MyApp(isLoggedIn: token != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth CRUD',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // This part will now work correctly
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}