import 'package:flutter/material.dart';
// บรรทัดนี้ถูกต้องตามโครงสร้างโปรเจกต์ของคุณ
import 'package:firstproject/screens/login_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(), // เรียกใช้หน้า Login ของเรา
    );
  }
}