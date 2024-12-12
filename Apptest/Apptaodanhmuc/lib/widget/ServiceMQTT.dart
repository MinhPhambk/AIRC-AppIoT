import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  final String broker = 'broker.emqx.io'; // Địa chỉ broke
  final int port = 1883;
  final String clientId = 'flutter_client_${DateTime.now().millisecondsSinceEpoch}';
  late MqttServerClient client;

  Future<void> connect() async {
    client = MqttServerClient(broker, clientId);
    client.port = port;
    client.keepAlivePeriod = 60;
    client.onDisconnected = onDisconnected;

    try {
      await client.connect();
      if (client.connectionStatus?.state == MqttConnectionState.connected) {
        print('Kết nối thành công đến MQTT broker');
      } else {
        print('Kết nối thất bại: ${client.connectionStatus}');
      }
    } catch (e) {
      print('Lỗi kết nối MQTT: $e');
      disconnect();
    }
  }

  void disconnect() {
    client.disconnect();
    print('Ngắt kết nối khỏi MQTT broker');
  }

  void onDisconnected() {
    print('Ngắt kết nối (callback)');
  }

  void publish(String topic, String message) {
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
      print('Đã gửi thông điệp: $message đến topic: $topic');
    } else {
      print('MQTT client chưa kết nối');
    }
  }
}