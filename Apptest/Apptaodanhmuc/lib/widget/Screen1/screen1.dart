import 'dart:convert';
import 'package:apptaodanhmuc/Component/item.dart';
import 'package:apptaodanhmuc/widget/Screen2/screen2.dart';
import 'package:apptaodanhmuc/widget/Screen3/line_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Controller/Bluetooth/blue_screen_scan.dart';

class Screen1 extends StatefulWidget {
  const Screen1({super.key});

  @override
  State<Screen1> createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  List<Map<String, dynamic>> devices = [];
  final List<Map<String, String>> testDevices = [
    {'title': 'LED', 'type': 'device'},
    {'title': 'FAN', 'type': 'device'},
    {'title': 'AIR', 'type': 'device'},
    {'title': 'SENSOR', 'type': 'sensor'},
  ];
  String? selectedDevice = "Choose Device"; // Lưu trữ thiết bị đã chọn

  @override
  void initState() {
    super.initState();
    _loadDevices(); // Tải danh sách thiết bị động
  }

  void _showDeviceSelectionDialog(BuildContext context) {
    final TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Chọn thiết bị và số lượng'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                hint: const Text('Chọn thiết bị'),
                value: selectedDevice, // Hiển thị giá trị đã chọn
                items: <String>['Choose Device', 'LED', 'FAN', 'AIR', 'SENSOR']
                    .map((String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                ))
                    .toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDevice = newValue; // Cập nhật giá trị đã chọn
                  });
                },
              ),
              if (selectedDevice != 'SENSOR')
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: 'Số lượng'),
                  keyboardType: TextInputType.number,
                ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Đóng popup khi hủy
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                if (selectedDevice == 'SENSOR') {
                  // Nếu chọn SENSOR, chuyển sang màn hình SensorDetailsScreen
                  Navigator.of(ctx).pop(); // Đóng popup

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LineChart(deviceName: selectedDevice!),
                    ),
                  );
                } else {
                  // Nếu chọn thiết bị khác, kiểm tra số lượng và chuyển sang màn hình tương ứng
                  final quantity = quantityController.text;

                  if (quantity.isNotEmpty) {
                    Navigator.of(ctx).pop(); // Đóng popup trước khi chuyển màn hình

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeviceScreen(
                          device: selectedDevice!,
                          quantity: int.parse(quantity),
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng nhập số lượng')),
                    );
                  }
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Lưu danh sách thiết bị động vào SharedPreferences
  Future<void> _saveDevices() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('dynamicDevices', jsonEncode(devices));
  }

// Tải danh sách thiết bị động từ SharedPreferences
  Future<void> _loadDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('dynamicDevices');
    if (jsonString != null) {
      setState(() {
        devices = List<Map<String, dynamic>>.from(jsonDecode(jsonString));
      });
    }
  }

  Future<void> _editDeviceName(BuildContext context, String currentName) async {
    // Hiển thị hộp thoại chỉnh sửa tên
    TextEditingController controller = TextEditingController(text: currentName);

    final String? newName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Device Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter device name'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.black)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Save', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
            ),
          ],
        );
      },
    );

    // Nếu người dùng nhập tên mới và tên đó không rỗng
    if (newName != null && newName.isNotEmpty) {
      // Tìm thiết bị theo tên hiện tại
      final index = devices.indexWhere((device) => device['title'] == currentName);

      if (index != -1) {
        // Cập nhật tên thiết bị trong danh sách
        setState(() {
          devices[index]['title'] = newName;
        });
        // Lưu lại danh sách thiết bị
        await _saveDevices();
        print("Tên thiết bị được đổi thành: $newName");
      } else {
        print("Không tìm thấy thiết bị với tên: $currentName");
      }
    } else {
      print("Người dùng hủy hoặc không nhập tên mới.");
    }
  }


  Future<void> _deleteDevice(BuildContext context, Map<String, dynamic> device) async {
    // Hiển thị pop-up xác nhận
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this device?'),
          actions: [
            TextButton(
              child: const Text('Cancel',style: TextStyle(color: Colors.black)),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: const Text('Delete',style: TextStyle(color: Colors.black)),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );

    // Nếu người dùng chọn "Delete"
    if (confirmDelete == true) {
      setState(() {
        devices.remove(device);
      });
      await _saveDevices();
      print('Delete: $device');
    }
  }

  Future<void> _checkBluetoothAndNavigate() async {
    // Kiểm tra trạng thái Bluetooth
    final isBluetoothOn = await FlutterBluePlus.adapterState. first;

    if (isBluetoothOn != BluetoothAdapterState.on) {
      // Hiển thị popup yêu cầu bật Bluetooth
      final shouldEnable = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Bluetooth is off'),
            content: const Text('You need to enable Bluetooth to proceed'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel',style: TextStyle(color: Colors.black)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Enable Bluetooth',style: TextStyle(color: Colors.black)),
              ),
            ],
          );
        },
      );

      // Nếu người dùng đồng ý bật Bluetooth
      if (shouldEnable == true) {
        await FlutterBluePlus.turnOn();
      } else {
        return; // Không làm gì nếu người dùng từ chối
      }
    }

    // Nếu Bluetooth đã bật, chuyển sang màn hình DeviceListScreen
    final selectedDevice = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DeviceListScreen()),
    );

    // Nếu nhận được kết quả, thêm thiết bị vào danh sách
    if (selectedDevice != null && selectedDevice is String) {
      setState(() {
        devices.add({'title': selectedDevice});
      });
      await _saveDevices();
    }
  }

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
      body: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemCount: devices.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
            onTap: (){_showDeviceSelectionDialog(context);},
            child: Items(
            title: devices[index]['title'], context: context,
              onEdit: (ctx, _) => _editDeviceName(ctx, devices[index]['title']), // Gọi đúng hàm edit
              onDelete: () {
                _deleteDevice(context, devices[index]);
              },
            ),
            );
          }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          await _checkBluetoothAndNavigate();
        },
        backgroundColor: const Color(0xFF33CCFF),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}