import 'dart:async';

import 'package:apptaodanhmuc/Component/item.dart';
import 'package:flutter/material.dart';
import '../../Controller/MQTT/ServiceMQTT.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key, required this.device, required this.quantity});
  final String device;
  final int quantity;

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  final mqttService = MqttService();
  List<bool?> toggleStates = []; // Sử dụng nullable bool để dễ dàng nhận giá trị null
  bool isLoading = true; // Variable to control loading state
  List<StreamController<int>> fanModeControllers = [];

  @override
  void initState() {
    super.initState();
    //mqttService.connect();
    toggleStates = List.filled(widget.quantity, null); // Khởi tạo với null, chưa có trạng thái
    fanModeControllers = List.generate(widget.quantity, (_) => StreamController<int>());
    // Simulate the delay for loading
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false; // After 5 seconds, stop showing the loading indicator
      });
    });

    // Kết nối và subscribe vào MQTT
    mqttService.connect().then((_) {
      for (int i = 0; i < widget.quantity; i++) {
        String topic = '/AIRC/${convertToTopic('${widget.device} ${i + 1}')}/';
        mqttService.subscribe(topic, (message) {
          if (widget.device.contains('FAN')) {
            int fanMode = _parseFanMode(message);
            fanModeControllers[i].add(fanMode); // Gửi dữ liệu đến FanModeControl
          } else {
            bool newState = (message == 'on');
            setState(() {
              toggleStates[i] = newState;
            });
          }
        });
      }
    });
  }
  // Helper to parse FAN mode from message
  int _parseFanMode(String message) {
    switch (message) {
      case "00":
        return 0; // OFF
      case "25":
        return 1; // Speed 1
      case "50":
        return 2; // Speed 2
      case "99":
        return 3; // Speed 3
      default:
        return 0; // Default to OFF if unknown
    }
  }

  @override
  void dispose() {
    for (var controller in fanModeControllers) {
      controller.close();
    }
    mqttService.disconnect();
    super.dispose();
  }

  int? extractDeviceIndexFromTopic(String topic) {
    final regex = RegExp(r'/AIRC/LED(\d+)/');
    final match = regex.firstMatch(topic);
    if (match != null) {
      return int.tryParse(match.group(1)!)! - 1;
    }
    return null;
  }
  String convertToTopic(String input) {
    if (input.contains("LED")) {
      final id = RegExp(r'LED\s*(\d+)').firstMatch(input)?.group(1);
      return 'LED$id';
    } else if (input.contains("FAN")) {
      final id = RegExp(r'FAN\s*(\d+)').firstMatch(input)?.group(1);
      return 'Fan$id';
    }
    throw ArgumentError('Chuỗi không hợp lệ: $input');
  }
  void handleDeviceToggle(String deviceName, bool value) {
    String topic = '/AIRC/${convertToTopic(deviceName)}/';
    String message = value ? "on" : "off";
    mqttService.publish(topic, message);
    print('Đã gửi thông điệp: $message đến topic: $topic');

    // Cập nhật trạng thái của UI
    int index = int.parse(deviceName.split(' ')[1]) - 1;
    setState(() {
      toggleStates[index] = value;
    });
  }

  void handleDeviceToggleFan(String deviceName, int value) {
    String topic = '/AIRC/${convertToTopic(deviceName)}/';

    if (value == 0) {
      String message = "00";
      mqttService.publish(topic, message);
      print('Đã gửi thông điệp: $message đến topic: $topic');
    } else if (value == 1) {
      String message = "25";
      mqttService.publish(topic, message);
      print('Đã gửi thông điệp: $message đến topic: $topic');
    } else if (value == 2) {
      String message = "50";
      mqttService.publish(topic, message);
      print('Đã gửi thông điệp: $message đến topic: $topic');
    } else if (value == 3) {
      String message = "99";
      mqttService.publish(topic, message);
      print('Đã gửi thông điệp: $message đến topic: $topic');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF33CCFF),
        title: Text(widget.device,style: const TextStyle(
            color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold)),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(), // Show loading indicator
      )
      : GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2),
          itemCount: widget.quantity,
          itemBuilder: (BuildContext context, int index) {
            return Items(
                title: '${widget.device} ${index + 1}',
                context: context,
              initialSwitchState: toggleStates[index], // Trạng thái MQTT
              onToggle: handleDeviceToggle,
              onFanModeChanged: handleDeviceToggleFan,
              fanModeStream: widget.device.contains('FAN')
                  ? fanModeControllers[index].stream
                  : null, // Stream cho FAN
            );
          }
      ),
    );
  }
}