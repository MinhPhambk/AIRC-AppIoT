import 'dart:convert';
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
    controller
        .scanDevices(); // Start scanning as soon as the screen is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF33CCFF),
        title: const Text(
          "Bluetooth Devices",
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
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
                          title: Text(
                            data.device.platformName.isEmpty
                                ? "Unknown Device"
                                : data.device.platformName,
                          ),
                          subtitle: Text(data.device.remoteId.str),
                          trailing: Text("RSSI: ${data.rssi}"),
                          onTap: () async {
                            // Kết nối với thiết bị Bluetooth
                            bool isConnected =
                            await controller.connectToDevice(data.device);

                            if (isConnected) {
                              // Nếu kết nối thành công, hiển thị popup
                              showDialog(
                                context: context,
                                builder: (context) {
                                  TextEditingController firstInputController =
                                  TextEditingController();
                                  TextEditingController secondInputController =
                                  TextEditingController();

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
                                        child: const Text(
                                          "CLOSE",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          String ssid =
                                              firstInputController.text;
                                          String password =
                                              secondInputController.text;

                                          if (ssid.isNotEmpty &&
                                              password.isNotEmpty) {
                                            try {
                                              // // Thiết lập MTU (giả sử 512, có thể thay đổi theo thiết bị)
                                              // const int mtuSize = 23;
                                              // await data.device.requestMtu(mtuSize);
                                              // print("MTU được thiết lập thành công: $mtuSize");

                                              // Chuẩn bị dữ liệu Wi-Fi dưới dạng JSON
                                              Map<String, String> wifiData = {
                                                "SSID": ssid,
                                                "PASSWORD": password,
                                              };
                                              // Chuyển đổi Map thành JSON string
                                              String jsonData = jsonEncode(wifiData);

                                              // Gửi dữ liệu JSON qua Bluetooth
                                              await controller.sendWiFiCredentials(data.device, jsonData);
                                              print("Chuỗi JSON được tạo: $jsonData");

                                              // Nhận dữ liệu phản hồi từ ESP32
                                              var receivedData = await controller.receiveDataFromDevice(data.device);
                                              print("Nhận data: ${data.device}");

                                              // Kiểm tra dữ liệu phản hồi
                                              if (receivedData != null && receivedData.isNotEmpty) {
                                                print("Dữ liệu nhận được từ ESP32: $receivedData");

                                                // Thông báo thành công
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text("Wi-Fi credentials sent successfully!")),
                                                );

                                                // Đóng dialog
                                                Navigator.of(context).pop();

                                                // Chuyển về màn hình trước đó với tên thiết bị
                                                String deviceName = data.device.platformName.isEmpty
                                                    ? "Unknown Device"
                                                    : data.device.platformName;
                                                Navigator.of(context).pop(deviceName);
                                              } else {
                                                // Nếu không nhận được dữ liệu phản hồi, hiển thị thông báo
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                      content: Text("No response data received from ESP32!")),
                                                );
                                              } // Quay lại màn 1, Trả về tên thiết bị
                                            } catch (e) {
                                              // Hiển thị lỗi nếu gửi thất bại
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        "Failed to send Wi-Fi credentials: $e")),
                                              );
                                            }
                                          } else {
                                            // Thông báo nếu người dùng chưa nhập tên Wi-Fi hoặc mật khẩu
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      "Please enter both Wi-Fi name and password")),
                                            );
                                          }
                                        },
                                        child: const Text(
                                          "OK",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              // Nếu kết nối thất bại, hiển thị thông báo lỗi
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        "Failed to connect to device: ${data.device.platformName}")),
                              );
                            }
                          }),
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
