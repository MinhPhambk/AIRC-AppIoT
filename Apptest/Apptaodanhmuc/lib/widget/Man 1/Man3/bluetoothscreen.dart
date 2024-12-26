import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'ble_controller.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  late BleController controller;

  @override
  void initState() {
    super.initState();
    // Initialize the controller and start scanning
    controller = Get.put(BleController());
    controller.scanDevices(); // Start scanning as soon as the screen is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF33CCFF),
        title: const Text("Bluetooth Devices",
          style: TextStyle(fontSize: 30, color: Colors.white),),
      ),
      body: GetBuilder<BleController>(
        builder: (controller) {
          return StreamBuilder<List<ScanResult>>(
            stream: controller.scanResults,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final data = snapshot.data![index];
                    return Card(
                      elevation: 2,
                      child: ListTile(
                        title: Text(data.device.platformName.isEmpty
                            ? "Unknown Device"
                            : data.device.platformName,
                        ),
                        subtitle: Text(data.device.remoteId.str),
                        trailing: Text("RSSI: ${data.rssi}"),
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context){
                                TextEditingController firstInputController = TextEditingController();
                                TextEditingController secondInputController = TextEditingController();

                                return AlertDialog(
                                  title: const Text('Add Wifi'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: firstInputController,
                                        decoration: const InputDecoration(
                                          hintText: "Wifi's name",
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      TextField(
                                        controller: secondInputController,
                                        decoration: const InputDecoration(
                                          hintText: "Password",
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("CLOSE",style: TextStyle(color: Colors.black),),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        String deviceName = data.device.platformName.isEmpty
                                            ? "Unknown Device"
                                            : data.device.platformName;

                                        // Đóng AlertDialog và quay về màn hình trước đó
                                        Navigator.of(context).pop(); // Đóng dialog
                                        Navigator.of(context).pop(deviceName); // Quay lại màn 1, Trả về tên thiết bị
                                      },
                                      child: const Text("OK",style: TextStyle(color: Colors.black),),
                                    ),
                                  ],
                                );
                              }
                          );
                        },
                      ),
                    );
                  },
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else {
                return const Center(child: Text("No devices found..."));
              }
            },
          );
        },
      ),
    );
  }
}