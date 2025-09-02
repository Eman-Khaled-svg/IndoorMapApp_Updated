import 'package:flutter/material.dart';

class FavoritePlacesScreen extends StatelessWidget {
  const FavoritePlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الأماكن المفضلة'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Text('شاشة الأماكن المفضلة (بدون بيانات حالياً)', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}