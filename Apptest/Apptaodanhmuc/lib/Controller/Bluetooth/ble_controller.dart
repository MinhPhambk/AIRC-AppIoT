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
  //             // Nếu dữ liệu không phải chuỗi UTF-8 hợp lệ, thử chuyển nó thành chuỗi hex
  //             String hexString = data.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ');
  //             print("Dữ liệu dưới dạng hex: $hexString");
  //
  //             // Chuyển đổi từ chuỗi hex sang chuỗi UTF-8 (nếu có thể)
  //             String receivedString = utf8.decode(data, allowMalformed: true);
  //             print("Dữ liệu chuỗi nhận được: $receivedString");
  //
  //             // Thử phân tích JSON nếu là chuỗi JSON hợp lệ
  //             try {
  //               Map<String, dynamic> jsonMap = jsonDecode(receivedString);
  //               print("JSON được phân tích: $jsonMap");
  //             } catch (jsonError) {
  //               print("Dữ liệu không phải JSON hợp lệ: $jsonError");
  //             }
  //           } catch (e) {
  //             print("Lỗi khi phân tích dữ liệu: $e");
  //           }
  //
  //           break; // Ngừng lắng nghe sau khi nhận 1 gói dữ liệu
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
  //       //await device.disconnect();
  //       print("Ngắt kết nối sau khi nhận dữ liệu từ ESP32.");
  //     } catch (e) {
  //       print("Lỗi khi ngắt kết nối: $e");
  //     }
  //   }
  //   return null;
  // }
  // Future<String?> receiveDataFromDevice(BluetoothDevice device) async {
  //   try {
  //     // Khám phá dịch vụ và đặc tính
  //     List<BluetoothService> services = await device.discoverServices();
  //     BluetoothCharacteristic? notifyCharacteristic;
  //
  //     // Tìm đặc tính hỗ trợ notify
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
  //       // Lắng nghe và nhận dữ liệu
  //       List<int> receivedData = [];
  //       bool receivedAllData = false;
  //
  //       await for (var data in notifyCharacteristic.lastValueStream) {
  //         if (data.isNotEmpty) {
  //           print("Dữ liệu thô nhận được: $data");
  //
  //           // Ghép nối dữ liệu vào danh sách
  //           receivedData.addAll(data);
  //
  //           // Giả sử dữ liệu đầy đủ khi đã nhận được một lượng dữ liệu lớn (hoặc đủ theo yêu cầu)
  //           if (receivedData.length > 100) { // Bạn có thể điều chỉnh điều kiện này
  //             receivedAllData = true;
  //             break; // Đủ dữ liệu, dừng nhận
  //           }
  //         }
  //       }
  //
  //       // Kiểm tra xem đã nhận đủ dữ liệu chưa
  //       if (receivedAllData) {
  //         print("Dữ liệu đầy đủ đã nhận được.");
  //
  //         // Giải mã dữ liệu nhận được
  //         String receivedString = utf8.decode(receivedData);
  //         print("Dữ liệu chuỗi nhận được: $receivedString");
  //
  //         try {
  //           Map<String, dynamic> jsonMap = jsonDecode(receivedString);
  //           print("Dữ liệu JSON: $jsonMap");
  //         } catch (e) {
  //           print("Lỗi khi phân tích JSON: $e");
  //         }
  //       } else {
  //         print("Dữ liệu không đầy đủ hoặc không nhận được.");
  //       }
  //
  //       // Đợi thời gian chờ trước khi ngắt kết nối
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
  Future<Map<String, dynamic>?> receiveDataFromDevice(BluetoothDevice device) async {
    try {
      List<BluetoothService> services = await device.discoverServices();
      BluetoothCharacteristic? notifyCharacteristic;

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

        Completer<Map<String, dynamic>?> completer = Completer<Map<String, dynamic>?>(); // Thay đổi kiểu Completer
        List<int> receivedData = [];
        late StreamSubscription? subscription;

        subscription = notifyCharacteristic.lastValueStream.listen((data) {
          if (data.isNotEmpty) {
            receivedData.addAll(data);

            if (data.contains(10)) {
              String receivedString = utf8.decode(receivedData);
              print("Dữ liệu chuỗi nhận được: $receivedString");

              if (receivedString.startsWith('{') || receivedString.startsWith('[')) {
                try {
                  Map<String, dynamic> jsonMap = jsonDecode(receivedString);
                  print("Dữ liệu JSON: $jsonMap");
                  completer.complete(jsonMap); // Giờ đây kiểu dữ liệu đã khớp
                } catch (e) {
                  print("Lỗi khi phân tích JSON: $e");
                  completer.completeError("Lỗi JSON: $e");
                }
              } else {
                print("Dữ liệu không phải JSON: $receivedString");
                completer.complete(null);
              }
              subscription?.cancel();
              return;
            }
          }
        }, onError: (error) {
          print("Lỗi khi nhận dữ liệu từ Stream: $error");
          completer.completeError("Lỗi Stream: $error");
        });

        Map<String, dynamic>? result = await completer.future.timeout(const Duration(seconds: 10), onTimeout: () {
          print("Đã hết thời gian chờ nhận dữ liệu.");
          subscription?.cancel();
          return null;
        });

        await Future.delayed(const Duration(seconds: 1));
        await notifyCharacteristic.setNotifyValue(false);
        print("Đã tắt thông báo từ characteristic.");

        return result;
      } else {
        print("Không tìm thấy characteristic hỗ trợ notify.");
      }
    } catch (e) {
      print("Lỗi khi nhận dữ liệu: $e");
    } finally {
      try {
        BluetoothConnectionState state = await device.connectionState.firstWhere((s) => true).timeout(const Duration(seconds: 1));
        if (state == BluetoothConnectionState.connected) {
          await device.disconnect();
          print("Ngắt kết nối sau khi nhận dữ liệu.");
        }
      } catch (e) {
        print("Lỗi khi kiểm tra trạng thái kết nối hoặc ngắt kết nối: $e");
      }
    }
    return null;
  }
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;
}