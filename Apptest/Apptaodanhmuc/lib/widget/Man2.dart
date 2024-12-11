import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:confirm_dialog/confirm_dialog.dart';

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
  late List<int> selectedModes; // Danh sách chế độ của từng quạt
  final List<String> items = ['SELECT', 'Chế độ 1', 'Chế độ 2', 'Chế độ 3'];
  List<String?> selectedItems=[];//để lưu trạng thái lựa chọn riêng cho từng điều hòa.
  late List<int> temperature; // Nhiệt độ riêng cho từng điều hòa
  //tăng nhiệt độ tối đa 30
  void _incrementCounter(int index) {
    setState(() {
      if(temperature[index]<30){
        temperature[index]++;
      }
    });
  }
  //giảm nhiệt độ tối đa 16
  void _decrementCounter(int index) {
    setState(() {
      if(temperature[index]>18){
        temperature[index]--;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    devices = _getDevicesForCategory(widget.category);

    //Số lượng thiết bị và trạng thái ban đầu
    toggleStates = List<bool>.filled(devices.length, false);
    // Mặc định là chế độ "OFF" cho tất cả
    selectedModes = List<int>.filled(devices.length, 0);
    selectedItems = List<String?>.filled(devices.length, 'SELECT'); // Trạng thái SELECT DROP
    temperature = List<int>.filled(devices.length, 18);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF33CCFF),
        title: Center(
          child: Text(
            'THIẾT BỊ ${widget.category}',
            style: const TextStyle(fontSize: 30, color: Colors.white),
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
                        padding: widget.category == 'ĐIỀU HÒA'
                        ? const EdgeInsets.symmetric(vertical: 12)
                        : const EdgeInsets.symmetric(vertical: 20),
                        child: Column(

                          mainAxisAlignment: widget.category == 'ĐIỀU HÒA'||widget.category == 'QUẠT'
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.spaceBetween,
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
                                            : widget.category == 'QUẠT'
                                                ? FontAwesomeIcons.fan
                                                : Icons.sensors,
                                size: widget.category == 'ĐIỀU HÒA'
                                ? 48 : 60,
                              ),
                            ),
                            Text(
                              devices[index],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            if (widget.category == 'QUẠT') ...[
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(4, (modeIndex) {
                                  bool isSelected =
                                      selectedModes[index] == modeIndex;
                                  // Label for each mode
                                  String label;
                                  if (modeIndex == 0) {
                                    //Nếu index == 0, nội dung nút là "OFF"
                                    label = "OFF";
                                  } else {
                                    //Không, nội dung là số (1, 2, hoặc 3)
                                    label = "$modeIndex";
                                  }
                                  return GestureDetector(
                                    onTap: () {
                                      //hàm setState() được gọi để cập nhật giá trị selectedMode thành index của nút đó
                                      setState(() {
                                        selectedModes[index] = modeIndex;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2.5, horizontal: 6),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? (modeIndex == 0
                                            ? Colors.red
                                            : Colors.green)
                                            : Colors.white,
                                        border: Border.all(color: Colors.black),

                                        //Bo góc
                                        borderRadius: BorderRadius.only(
                                          //Mode OFF (trái bo 15px, phải không bo)
                                          topLeft: modeIndex == 0
                                              ? const Radius.circular(7.5)
                                              : Radius.zero,
                                          // Bo góc trái trên
                                          bottomLeft: modeIndex == 0
                                              ? const Radius.circular(7.5)
                                              : Radius.zero,
                                          // Bo góc trái dưới
                                          //Mode 3 (trái bo 15px, phải không bo)
                                          topRight: modeIndex == 3
                                              ? const Radius.circular(7.5)
                                              : Radius.zero,
                                          // Bo góc phải trên
                                          bottomRight: modeIndex == 3
                                              ? const Radius.circular(7.5)
                                              : Radius.zero, // Bo góc phải dưới
                                        ),
                                      ),
                                      child: Text(
                                        label,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ]
                              //select drop
                            else if (widget.category == 'ĐIỀU HÒA') ...[
                              // Container làm Select Drop
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Container(
                                        padding: const EdgeInsets.all(10),
                                        height: 200, // Đặt chiều cao cố định
                                        child: ListView.builder(
                                          itemCount: items.length,
                                          itemBuilder: (BuildContext context, int itemIndex) {
                                            return ListTile(
                                              title: Text(items[itemIndex]),
                                              onTap: () {
                                                setState(() {
                                                  // Cập nhật đúng điều hòa
                                                  selectedItems[index] = items[itemIndex];;
                                                });
                                                Navigator.pop(context); // Đóng BottomSheet
                                              },
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 9,
                                    right: 9,
                                    bottom: 13,
                                  ),
                                  child: Container(
                                    //text trong container
                                    padding:  const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: Colors.black.withOpacity(0.5)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          selectedItems[index] ?? 'SELECT',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_drop_down,
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                constraints: const BoxConstraints(
                                  maxWidth: 113,
                                  maxHeight: 30, // Giới hạn chiều cao
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.lightBlue,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                        size: 13,
                                      ),
                                      color: Colors.white,
                                      onPressed: () => _incrementCounter(index),
                                    ),
                                    Text(
                                      '${temperature[index]}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        size: 13,
                                      ),
                                      color: Colors.white,
                                      onPressed: () => _decrementCounter(index),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ],
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: widget.category == 'QUẠT'
                        ? const EdgeInsets.symmetric(vertical: 5, horizontal: 5)
                        : const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                        child: Column(
                          mainAxisAlignment:widget.category == 'QUẠT'
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.spaceBetween,
                          children: [
                            if (widget.category != 'QUẠT') ...[
                              AnimatedToggleSwitch.dual(
                                current: toggleStates[index],
                                first: false,
                                second: true,
                                spacing: 5,
                                animationDuration:
                                    const Duration(milliseconds: 400),
                                style: const ToggleStyle(
                                  borderColor: Colors.transparent,
                                  indicatorColor: Colors.white,
                                ),
                                customStyleBuilder: (context, local, global) {
                                  if (global.position <= 0) {
                                    return ToggleStyle(
                                        backgroundColor: Colors.red[800]);
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
                                height: 20,
                                //độ rộng của nút
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
                                    ? const Icon(Icons.power,
                                        color: Colors.green, size: 15)
                                    : Icon(Icons.power_settings_new,
                                        color: Colors.red[800], size: 15),
                              ),
                            ],

                            if (widget.category == 'QUẠT') ...[
                              const SizedBox.shrink(),
                            ], // Không hiển thị gì cả

                            IconButton(
                              icon: const Icon(Icons.edit,
                                  size: 35, color: Colors.black),
                              onPressed: () async {
                                if (await confirm(
                                  context,
                                  title: const Text('Device Name'),
                                  content: const TextField(
                                    decoration: InputDecoration(
                                        hintText: 'Enter device name'),
                                  ),
                                  textOK: const Text(
                                    'Yes',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  textCancel: const Text(
                                    'No',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                )) {
                                  return print('pressedOK');
                                }
                                return print('pressedCancel');
                              },
                            ),

                            if (widget.category == 'QUẠT')...[
                            const SizedBox(height: 35)],

                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 35, color: Colors.black),
                              onPressed: () async {
                                if (await confirm(
                                  context,
                                  title: const Text('Confirm'),
                                  content:
                                      const Text('Would you like to remove?'),
                                  textOK: const Text(
                                    'Yes',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  textCancel: const Text(
                                    'No',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                )) {
                                  return print('pressedOK');
                                }
                                return print('pressedCancel');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
      case 'CẢM BIẾN':
        return ['Cảm Biến 1', 'Cảm Biến 2', 'Cảm Biến 3'];
      default:
        return [];
    }
  }
}
