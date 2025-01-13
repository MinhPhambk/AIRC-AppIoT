import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class BleController extends GetxController{

  FlutterBluePlus ble = FlutterBluePlus();

  Future<void> requestPermissions() async {
    if (await Permission.bluetoothScan.isDenied) {
      await Permission.bluetoothScan.request();
    }
    if (await Permission.bluetoothConnect.isDenied) {
      await Permission.bluetoothConnect.request();
    }
    if (await Permission.locationWhenInUse.isDenied) {
      await Permission.locationWhenInUse.request();
    }
  }

// This Function will help users to scan near by BLE devices and get the list of Bluetooth devices.
  Future scanDevices() async {
    requestPermissions();
    if (await Permission.bluetoothScan.request().isGranted) {
      if (await Permission.bluetoothConnect.request().isGranted) {
        // Bắt đầu quét
        FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));

        // Lắng nghe kết quả quét
        FlutterBluePlus.scanResults.listen((scanResults) {
          for (ScanResult result in scanResults) {
            print("Device found: ${result.device.platformName}, RSSI: ${result.rssi}");
          }
        });
        //
        await Future.delayed(const Duration(seconds: 30));
        FlutterBluePlus.stopScan();
      }
    }
  }

//This function will help user to connect to BLE devices.
  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect(timeout: const Duration(seconds: 15));

      // Lắng nghe trạng thái kết nối
      device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.connected) {
          print("Connected to device: ${device.platformName}");
        } else if (state == BluetoothConnectionState.disconnected) {
          print("Device disconnected");
        }
      });
      return true; // Kết nối thành công
    } catch (e) {
      print("Error connecting to device: $e");
      return false; // Kết nối thất bại
    }
  }

  Future<void> sendWiFiCredentials(BluetoothDevice device, String jsonData) async {
    try {
      // Kết nối với thiết bị
      await device.connect();

      // Lấy danh sách dịch vụ
      List<BluetoothService> services = await device.discoverServices();
      BluetoothCharacteristic? targetCharacteristic;

      // Tìm kiếm characteristic hỗ trợ ghi
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            targetCharacteristic = characteristic;
            break;
          }
        }
        if (targetCharacteristic != null) break;
      }

      if (targetCharacteristic != null) {
        // Gửi chuỗi JSON qua Bluetooth
        List<int> bytes = utf8.encode(jsonData);
        await targetCharacteristic.write(bytes, withoutResponse: false);

        print("Dữ liệu Wi-Fi (JSON) đã được gửi: $jsonData");
        // Nhận dữ liệu phản hồi từ ESP32 sau khi gửi
        await receiveDataFromDevice(device);
      } else {
        print("Không tìm thấy characteristic hỗ trợ ghi");
      }
    } catch (e) {
      print("Lỗi khi gửi dữ liệu: $e");
    }
  }

  // Future<String?> receiveDataFromDevice(BluetoothDevice device) async {
  //   try {
  //     // Khám phá dịch vụ và đặc tính
  //     List<BluetoothService> services = await device.discoverServices();
  //     BluetoothCharacteristic? notifyCharacteristic;
  //
  //     for (var service in services) {
  //       for (var characteristic in service.characteristics) {
  //         if (characteristic.properties.notify) {
  //           notifyCharacteristic = characteristic;
  //           break;
  //         }
  //       }
  //       if (notifyCharacteristic != null) break;
  //     }
  //
  //     if (notifyCharacteristic != null) {
  //       await notifyCharacteristic.setNotifyValue(true);
  //       print("Đã bật thông báo từ characteristic.");
  //
  //       // Lắng nghe dữ liệu
  //       await for (var data in notifyCharacteristic.lastValueStream) {
  //         if (data.isNotEmpty) {
  //           // In dữ liệu thô (List<int>)
  //           print("Dữ liệu thô nhận được: $data");
  //
  //           try {
  //             // Chuyển dữ liệu thành chuỗi UTF-8 và in ra
  //             String receivedString = utf8.decode(data);
  //             print("Dữ liệu chuỗi nhận được: $receivedString");
  //
  //             // Thử phân tích JSON
  //             Map<String, dynamic> jsonMap = jsonDecode(receivedString);
  //             print("JSON được phân tích: $jsonMap");
  //           } catch (e) {
  //             print("Lỗi khi phân tích JSON: $e");
  //           }
  //           break;
  //         }
  //       }
  //
  //       // Thời gian chờ 10 giây trước khi ngắt kết nối
  //       print("Đợi 10 giây trước khi ngắt kết nối...");
  //       await Future.delayed(const Duration(seconds: 10));
  //       await notifyCharacteristic.setNotifyValue(false);
  //       print("Đã tắt thông báo từ characteristic.");
  //     } else {
  //       print("Không tìm thấy characteristic hỗ trợ notify.");
  //     }
  //   } catch (e) {
  //     print("Lỗi khi nhận dữ liệu: $e");
  //   } finally {
  //     try {
  //       await device.disconnect();
  //       print("Ngắt kết nối sau khi nhận dữ liệu từ ESP32.");
  //     } catch (e) {
  //       print("Lỗi khi ngắt kết nối: $e");
  //     }
  //   }
  //   return null;
  // }

  // Future<String?> receiveDataFromDevice(BluetoothDevice device) async {
  //   try {
  //     // Kết nối với thiết bị
  //     await device.connect();
  //
  //     // Lấy danh sách dịch vụ
  //     List<BluetoothService> services = await device.discoverServices();
  //     BluetoothCharacteristic? targetCharacteristic;
  //
  //     // Tìm kiếm characteristic hỗ trợ ddojc
  //     for (var service in services) {
  //       for (var characteristic in service.characteristics) {
  //         if (characteristic.properties.read) {
  //           targetCharacteristic = characteristic;
  //           break;
  //         }
  //       }
  //       if (targetCharacteristic != null) break;
  //     }
  //     // List<List<int>> completeData = [];
  //     if (targetCharacteristic != null) {
  //       // Gửi chuỗi JSON qua Bluetooth
  //       List<int> value = await targetCharacteristic.read();
  //
  //       await targetCharacteristic.setNotifyValue(true);
  //       targetCharacteristic.lastValueStream.listen((value) {
  //         // completeData.add(value);
  //         print("innnnnn ----------> $value");
  //         String jsonString = String.fromCharCodes(value);
  //
  //         print('Decoded String: $jsonString');
  //
  //       });
  //       // print("completeData: $completeData");
  //
  //       // print("----------> $value");
  //       // await targetCharacteristic.write(bytes, withoutResponse: false);
  //
  //       // Nhận dữ liệu phản hồi từ ESP32 sau khi gửi
  //       // await receiveDataFromDevice(device);
  //     } else {
  //       print("Không tìm thấy characteristic hỗ trợ ghi");
  //     }
  //   } catch (e) {
  //     print("Lỗi khi gửi dữ liệu: $e");
  //   }
  //
  //   return "";
  // }

  Future<String?> receiveDataFromDevice(BluetoothDevice device) async {
    try {
      // Khám phá dịch vụ và đặc tính
      List<BluetoothService> services = await device.discoverServices();
      BluetoothCharacteristic? notifyCharacteristic;

      // Tìm đặc tính hỗ trợ notify
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.notify) {
            notifyCharacteristic = characteristic;
            break;
          }
        }
        if (notifyCharacteristic != null) break;
      }

      if (notifyCharacteristic != null) {
        await notifyCharacteristic.setNotifyValue(true);
        print("Đã bật thông báo từ characteristic.");

        // Lắng nghe và nhận dữ liệu
        List<int> receivedData = [];
        bool receivedAllData = false;

        await for (var data in notifyCharacteristic.lastValueStream) {
          if (data.isNotEmpty) {
            print("Dữ liệu thô nhận được: $data");

            // Ghép nối dữ liệu vào danh sách
            receivedData.addAll(data);

            // Kiểm tra ký tự cuối (giả sử dụng \n là ký tự kết thúc dữ liệu)
            String partialString = String.fromCharCodes(receivedData);
            if (partialString.endsWith('}')) {
              receivedAllData = true;
              break;
            }
          }
        }

        // Kiểm tra xem đã nhận đủ dữ liệu chưa
        if (receivedAllData) {
          print("Dữ liệu đầy đủ đã nhận được.");

          // Giải mã dữ liệu nhận được
          String receivedString = String.fromCharCodes(receivedData);
          print("Dữ liệu chuỗi nhận được: $receivedString");

          try {
            Map<String, dynamic> jsonMap = jsonDecode(receivedString);
            print("Dữ liệu JSON: $jsonMap");
            return receivedString;
          } catch (e) {
            print("Lỗi khi phân tích JSON: $e");
          }
        } else {
          print("Dữ liệu không đầy đủ hoặc không nhận được.");
        }

        // Đợi thời gian chờ trước khi ngắt kết nối
        await Future.delayed(const Duration(seconds: 10));
        await notifyCharacteristic.setNotifyValue(false);
        print("Đã tắt thông báo từ characteristic.");
      } else {
        print("Không tìm thấy characteristic hỗ trợ notify.");
      }
    } catch (e) {
      print("Lỗi khi nhận dữ liệu: $e");
    } finally {
      try {
        await device.disconnect();
        print("Ngắt kết nối sau khi nhận dữ liệu từ ESP32.");
      } catch (e) {
        print("Lỗi khi ngắt kết nối: $e");
      }
    }
    return null;
  }

  // Future<Map<String, dynamic>?> receiveDataFromDevice(BluetoothDevice device) async {
  //   try {
  //     // Kiểm tra trạng thái kết nối trước khi đọc
  //     BluetoothConnectionState connectionState = await device.connectionState.first;
  //     if (connectionState != BluetoothConnectionState.connected) {
  //       print("Thiết bị chưa kết nối. Đang kết nối lại...");
  //       await device.connect();
  //     }
  //
  //     print("Thiết bị đã kết nối, bắt đầu khám phá dịch vụ...");
  //     List<BluetoothService> services = await device.discoverServices();
  //     print("Khám phá dịch vụ hoàn tất: ${services.length} dịch vụ được tìm thấy.");
  //
  //     // Tìm characteristic hỗ trợ read
  //     BluetoothCharacteristic? readCharacteristic;
  //     for (var service in services) {
  //       for (var characteristic in service.characteristics) {
  //         print("Đang kiểm tra characteristic: ${characteristic.uuid}");
  //         if (characteristic.properties.read) {
  //           print("Tìm thấy characteristic hỗ trợ read: ${characteristic.uuid}");
  //           readCharacteristic = characteristic;
  //           break;
  //         }
  //       }
  //       if (readCharacteristic != null) break;
  //     }
  //
  //     if (readCharacteristic != null) {
  //       // Đọc dữ liệu từ characteristic
  //       List<int> value = await readCharacteristic.read();
  //       print("Dữ liệu nhận được (raw bytes): $value");
  //
  //       // Chuyển đổi thành chuỗi
  //       String receivedString = utf8.decode(value);
  //       print("Dữ liệu nhận được (chuỗi): $receivedString");
  //
  //       // Phân tích JSON nếu dữ liệu hợp lệ
  //       if (receivedString.startsWith('{') && receivedString.endsWith('}')) {
  //         try {
  //           Map<String, dynamic> jsonMap = jsonDecode(receivedString);
  //           print("JSON nhận được: $jsonMap");
  //           return jsonMap;
  //         } catch (e) {
  //           print("Lỗi khi phân tích JSON: $e");
  //         }
  //       } else {
  //         print("Dữ liệu không phải JSON hợp lệ: $receivedString");
  //       }
  //     } else {
  //       print("Không tìm thấy characteristic hỗ trợ read.");
  //     }
  //   } catch (e) {
  //     print("Lỗi khi nhận dữ liệu: $e");
  //   } finally {
  //     try {
  //       BluetoothConnectionState state = await device.connectionState.first;
  //       if (state == BluetoothConnectionState.connected) {
  //         await device.disconnect();
  //         print("Ngắt kết nối sau khi nhận dữ liệu.");
  //       }
  //     } catch (e) {
  //       print("Lỗi khi kiểm tra trạng thái kết nối: $e");
  //     }
  //   }
  //   return null;
  // }

  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;
}