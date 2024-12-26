import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Man 2/Man2.dart';
import 'Man3/bluetoothscreen.dart';

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
  // Danh sách các thiết bị mặc định (các thiết bị không thể xóa)
  final List<String> defaultDevices = ['LED', 'FAN', 'AIR', 'TV', 'SENSORS'];

  Map<String, String> modifiedDefaultDevices = {}; // Lưu các tên mặc định đã được sửa
  // Map ánh xạ tên thiết bị với icon của nó
  final Map<String, IconData> deviceIcons = {
    'LED': Icons.lightbulb_outline,
    'FAN': FontAwesomeIcons.fan,
    'AIR': Icons.ac_unit_outlined,
    'TV': Icons.tv,
    'SENSORS': Icons.sensors,
  };
  List<Map<String, dynamic>> devices = [];//Danh sách thiết bị mới

  Future<void> _editDeviceName(BuildContext context, String currentName) async {
    print("Editing device: $currentName");  // Kiểm tra xem hàm có được gọi không

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
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty) {
      setState(() {
        if (defaultDevices.contains(currentName)) {
          modifiedDefaultDevices[currentName] = newName;  // Lưu tên sửa đổi cho thiết bị mặc định
        } else {
          devices.firstWhere((device) => device['title'] == currentName)['title'] = newName;
        }
      });
    }
    print('New Name: $newName');
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
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );

    // Nếu người dùng chọn "Delete"
    if (confirmDelete == true) {
      setState(() {
        if (defaultDevices.contains(device['title'])) {
          // Nếu là thiết bị mặc định, xóa khỏi danh sách mặc định
          defaultDevices.remove(device['title']);
        } else {
          // Nếu là thiết bị động, xóa khỏi danh sách devices
          devices.remove(device);
        }
      });
    }
    print('Delete: $device');
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2, //số cột
          crossAxisSpacing: 16, //khoảng cách các cột
          mainAxisSpacing: 16, //khoảng cách giữa các hàng
          children: [
            //Các thiết bị mặc định
            ...defaultDevices.map((device) {
              final displayName = modifiedDefaultDevices[device] ?? device; // Sử dụng tên sửa đổi nếu có
              return GridItemWidget(
                title: displayName,
                icon: deviceIcons[device] ?? Icons.devices,
                context: context,
                onEdit: (ctx, _) => _editDeviceName(ctx, device), // Gọi đúng hàm edit
                onDelete: () {
                  _deleteDevice(context, {'title': device});
                },
              );
            }).toList(),

            // Các thiết bị động
            ...devices.map((device) {
              return GridItemWidget(
                title: device['title'],
                icon: Icons.devices,
                context: context,
                device: device,
                onEdit: _editDeviceName,
                onDelete: () {
                  setState(() {
                    _deleteDevice(context, device);
                  });
                },
              );
            }).toList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          // Mở DeviceListScreen và chờ kết quả
          final selectedDevice = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context)=>const DeviceListScreen()),
          );
          // Nếu nhận được kết quả, thêm thiết bị vào danh sách động
          if (selectedDevice != null && selectedDevice is String) {
            setState(() {
              devices.add({'title': selectedDevice});
            });
          }
        },
        backgroundColor: const Color(0xFF33CCFF),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}

// Widget riêng cho GridItem
class GridItemWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final BuildContext context;
  final Map<String, dynamic>? device;
  final Future<void> Function(BuildContext, String)? onEdit;
  final VoidCallback? onDelete;

  const GridItemWidget({super.key,
    required this.title,
    required this.icon,
    required this.context,
    this.device,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Mở màn hình mới khi nhấn vào thiết bị
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
                        icon,
                        size: 70,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                      icon: const Icon(Icons.edit, size: 35, color: Colors.black),
                      onPressed: () {
                        if (device != null && onEdit != null) {
                          onEdit!(context, title); // chỉnh sửa tên
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 35, color: Colors.black),
                      onPressed: () {
                        if (onDelete != null) {
                          onDelete!();
                        }
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
  }
}