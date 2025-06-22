// ignore_for_file: unused_import, prefer_const_constructors, depend_on_referenced_packages

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:souq_tawfikia/Login_Page.dart';
import 'package:souq_tawfikia/SignUp_page.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDhxr8ReWyMsGxTst-9T8LQUlaiMDa7mos",
      appId: "1:1077345597502:android:abd51c7641557e42c0b96f",
      messagingSenderId: "1077345597502",
      projectId: "souq-tawfikia")
  );





  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp( // MaterialApp is not const because ThemeData is not const
      title: 'تسجيل الدخول - متجر السيارات', // تم تحديث العنوان
      debugShowCheckedModeBanner: false,
       // إعدادات دعم اللغة العربية
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', ''), // العربية
        Locale('en', ''), 
      ],
      locale: Locale('ar', ''), // تعيين اللغة الافتراضية إلى العربية

     // تطبيق الثيم الجديد (Neon Green)
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFFFEDDA), // الخلفية العامة
        primaryColor: Color(0xFF3DB2FF), // أزرق سماوي
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF3DB2FF), // أزرق
          secondary: Color(0xFFFFB830), // أصفر
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          error: Color(0xFFFF2442), // أحمر
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3DB2FF), // أزرق
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFFB830), // زر رئيسي أصفر
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),


      home: login_page(),
    );
  }
}

// تعريف ألوان الثيم الجديد (Neon Green)
// class NeonGreenTheme {
//   static const Color primaryNeon = Color(0xFF00FF7F); // لون أساسي
//   static const Color secondaryNeon = Color(0xFF7FFF00); // لون ثانوي
//   static const Color accentNeon = Color(0xFF39FF14); // لون مميز/تأكيدي
//   static const Color darkNeon = Color(0xFF00CC66); // لون أخضر داكن
//   static const Color lightNeon = Color(0xFFCCFF99); // لون أخضر فاتح
// }
