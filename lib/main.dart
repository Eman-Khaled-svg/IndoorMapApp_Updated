import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Indoor Map App",
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system, // الوضع الافتراضي (system)
      home: const SplashScreen(), // أول شاشة تظهر
      debugShowCheckedModeBanner: false,
    );
  }
}
