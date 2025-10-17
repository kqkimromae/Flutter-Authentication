// test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firstproject/main.dart';
import 'package:firstproject/screens/login_screen.dart';

void main() {
  // เปลี่ยนชื่อ test ให้อธิบายสิ่งที่เราจะทำ
  testWidgets('App shows LoginScreen when not logged in', (WidgetTester tester) async {
    
    // 1. Build แอพของเรา โดยส่งค่า isLoggedIn เป็น false
    //    เพื่อจำลองสถานการณ์ว่าผู้ใช้ยังไม่ได้ล็อกอิน
    await tester.pumpWidget(const MyApp(isLoggedIn: false));

    // 2. ตรวจสอบว่าหน้าจอ LoginScreen แสดงผลอยู่จริง
    //    โดยการหา Widget ที่มีอยู่เฉพาะในหน้า Login
    expect(find.byType(LoginScreen), findsOneWidget);

    // 3. ตรวจสอบให้ละเอียดขึ้นอีกนิด โดยหาข้อความ "Welcome Back!"
    expect(find.text('Welcome Back!'), findsOneWidget);
    
    // 4. ตรวจสอบว่าไม่มีปุ่มบวก (+) ของแอปเก่าอยู่
    expect(find.byIcon(Icons.add), findsNothing);
  });
}