import 'package:apptaodanhmuc/widget/Man1.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppIOT',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey, // Màu nền mặc định
      ),
      home: const Man1(),
    );
  }
}
