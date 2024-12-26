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

// This function will help user to connect to BLE devices.
 Future<void> connectToDevice(BluetoothDevice device)async {
    await device.connect(timeout: const Duration(seconds: 15));

    device.connectionState.listen((isConnected) {
      if(isConnected == BluetoothConnectionState.connected){
        print("Device connecting to: ${device.platformName}");
      }
      else{
        print("Device Disconnected");
      }
    });
 }

  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;
}