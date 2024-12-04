import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
        backgroundColor: Colors.blueAccent,
        title: const Center(
            child: Text(
          'HOME',
          style: TextStyle(fontSize: 24, color: Colors.white),
        )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2, //số cột
          crossAxisSpacing: 16, //khoảng cách các cột
          mainAxisSpacing: 16, //khoảng cách giữa các hàng
          children: [
            buildGridItem('Đèn', Icons.lightbulb),
            buildGridItem('Quạt', FontAwesomeIcons.fan),
            buildGridItem('Điều Hòa', Icons.ac_unit),
            buildGridItem('TV', Icons.tv),
            buildAddButton(),
          ],
        ),
      ),
    );
  }
}

Widget buildGridItem(String title, IconData icon) {
  return Container(
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Căn giữa theo trục dọc
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Icon(
                  icon,
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  //Xử lý sửa
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.blue),
                onPressed: () {
                  //Xử lý xóa
                },
              ),
            ],
          ),
        )
      ],
    ),
  );
}

Widget buildAddButton() {
  return GestureDetector(
    onTap: () {
      print('Hello');
      //Thêm thiết bị
    },
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: const Center(
        child: Icon(Icons.add, size: 50, color: Colors.blue),
      ),
    ),
  );
}
