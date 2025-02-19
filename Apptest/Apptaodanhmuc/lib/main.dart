import 'package:apptaodanhmuc/Controller/Cloud_MongoDB/MongoDB_service.dart';
import 'package:apptaodanhmuc/widget/Screen1/screen1.dart';
import 'package:flutter/material.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await MongoDBService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AppIOT',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFECECEC), // Màu nền mặc định
      ),
      home: const Screen1(),
    );
  }
}