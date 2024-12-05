import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/cupertino.dart';

class Man2 extends StatelessWidget {
  const Man2({super.key, required this.category});
  final String category;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppIOT',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFECECEC),
      ),
      home: Screen2(category: category),
    );
  }
}

class Screen2 extends StatefulWidget {
  const Screen2({super.key, required this.category});
  final String category;

  @override
  State<Screen2> createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  late List<bool> toggleStates; // Trạng thái của từng thiết bị
  late List<String> devices; // Danh sách thiết bị

  @override
  void initState() {
    /*Gọi phương thức initState của lớp cha (trong trường hợp này là State).
    Đảm bảo các logic khởi tạo cơ bản từ State được thực thi trước khi thêm logic tùy chỉnh.*/
    super.initState();
    devices = _getDevicesForCategory(widget.category);// danh sách thiết bị

    //Trong list.filled (số lượng thiết bị, trạng thái)
    toggleStates = List<bool>.filled(devices.length, false); // Tạo trạng thái ban đầu
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF33CCFF),
        title: Center(
          child: Text(
            'THIẾT BỊ ${widget.category}',
            style: const TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Số cột
            crossAxisSpacing: 16, // Khoảng cách giữa các cột
            mainAxisSpacing: 16, // Khoảng cách giữa các hàng
          ),
          itemCount: devices.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                print('Bạn đã chọn ${devices[index]}');
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Icon(
                                widget.category == 'ĐÈN'
                                    ? Icons.lightbulb_outline
                                    : widget.category == 'TV'
                                    ? Icons.tv
                                    : widget.category == 'ĐIỀU HÒA'
                                    ? Icons.ac_unit_outlined
                                    : FontAwesomeIcons.fan,
                                size: 60,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              devices[index],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AnimatedToggleSwitch.dual(
                              current: toggleStates[index],
                              first: false,
                              second: true,
                              spacing: 5,
                              animationDuration: const Duration(milliseconds: 350),
                              style: const ToggleStyle(
                                borderColor: Colors.transparent,
                                indicatorColor: Colors.white,
                                backgroundColor: Colors.black,
                              ),
                              customStyleBuilder: (context, local, global) {
                                if (global.position <= 0) {
                                  return ToggleStyle(backgroundColor: Colors.red[800]);
                                }
                                return ToggleStyle(
                                  backgroundGradient: LinearGradient(
                                    colors: [
                                      Colors.green,
                                      Colors.red[800]!,
                                    ],
                                    stops: [
                                      global.position -
                                          (1 - 2 * max(0, global.position - 0.5)) * 0.7,
                                      global.position +
                                          max(0, 2 * (global.position - 0.5)) * 0.7,
                                    ],
                                  ),
                                );
                              },
                              height: 30,
                              loadingIconBuilder: (context, global) =>
                                  CupertinoActivityIndicator(
                                    color: Color.lerp(
                                      Colors.red[800],
                                      Colors.green,
                                      global.position,
                                    ),
                                  ),
                              onChanged: (value) {
                                setState(() {
                                  toggleStates[index] = value;
                                });
                                print(
                                    'Thiết bị ${devices[index]}: ${value ? "BẬT" : "TẮT"}');
                              },
                              iconBuilder: (value) => value
                                  ? const Icon(Icons.lightbulb,
                                  color: Colors.green, size: 20)
                                  : Icon(Icons.lightbulb_outline,
                                  color: Colors.red[800], size: 20),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 30, color: Colors.black),
                              onPressed: () {
                                //print('Nhấn sửa ${devices[index]}');
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 30, color: Colors.black),
                              onPressed: () {
                                //print('Nhấn xóa ${devices[index]}');
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
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //print('Thêm thiết bị mới');
        },
        backgroundColor: const Color(0xFF33CCFF),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  List<String> _getDevicesForCategory(String category) {
    switch (category) {
      case 'ĐÈN':
        return ['Đèn 1', 'Đèn 2', 'Đèn 3'];
      case 'TV':
        return ['TV 1', 'TV 2', 'TV 3'];
      case 'ĐIỀU HÒA':
        return ['Điều hòa 1', 'Điều hòa 2', 'Điều hòa 3'];
      case 'QUẠT':
        return ['Quạt 1', 'Quạt 2', 'Quạt 3'];
      default:
        return [];
    }
  }
}
