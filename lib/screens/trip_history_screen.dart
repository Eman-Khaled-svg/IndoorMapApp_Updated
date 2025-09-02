import 'package:flutter/material.dart';

class TripHistoryScreen extends StatelessWidget {
  const TripHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('سجل الرحلات'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Text('شاشة سجل الرحلات (بدون بيانات حالياً)', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}