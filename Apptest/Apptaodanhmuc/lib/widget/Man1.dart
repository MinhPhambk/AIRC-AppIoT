import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'Man2.dart';
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
      home: const Man1(),
    );
  }
}

class Man1 extends StatefulWidget {
  const Man1({super.key});

  @override
  State<Man1> createState() => _Man1State();
}

class _Man1State extends State<Man1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF33CCFF),
        title: const Center(
            child: Text(
          'HOME',
          style: TextStyle(fontSize: 30, color: Colors.white),
        )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2, //số cột
          crossAxisSpacing: 16, //khoảng cách các cột
          mainAxisSpacing: 16, //khoảng cách giữa các hàng
          children: [
            buildGridItem('ĐÈN', Icons.lightbulb_outline,context),
            buildGridItem('QUẠT', FontAwesomeIcons.fan,context),
            buildGridItem('ĐIỀU HÒA', Icons.ac_unit_outlined,context),
            buildGridItem('TV', Icons.tv,context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('Thêm thiết bị mới');
        },
        backgroundColor: const Color(0xFF33CCFF),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}

Widget buildGridItem(String title, IconData icon, BuildContext context) {
  return GestureDetector(
    onTap: () {
      // Sử dụng context để chuyển sang màn hình khác
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Screen2(category: title)),
      );
    },
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Tách 2 bên
        crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa theo trục dọc
        children: [
          Expanded(
            flex: 2, // Định nghĩa tỷ lệ không gian cho cột này
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 37),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Căn giữa theo trục dọc
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Icon(
                      icon,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size:35, color: Color(0xFFBBBBBB)),
                    onPressed: () {
                      //Xử lý sửa
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size:35, color: Colors.black),
                    onPressed: () {
                      //Xử lý xóa
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    ),
  );
}