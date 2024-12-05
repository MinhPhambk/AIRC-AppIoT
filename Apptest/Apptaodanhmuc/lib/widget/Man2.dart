import 'package:flutter/material.dart';

class Man2 extends StatelessWidget {
  const Man2({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppIOT',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFECECEC), // Màu nền mặc định
      ),
      home: const Screen2(),
    );
  }
}

class Screen2 extends StatefulWidget {
  const Screen2({super.key});

  @override
  State<Screen2> createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF33CCFF),
        title: const Center(
          child: Text(
            'THIẾT BỊ',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
