import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  final String broker = 'broker.emqx.io'; // Địa chỉ broke
  final int port = 1883;
  final String clientId = 'flutter_client_${DateTime.now().millisecondsSinceEpoch}';
  late MqttServerClient client;
  final Map<String, Function(String)> _topicCallbacks = {}; // Lưu các callback theo topic

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
      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!,retain: true);
      print('Đã gửi thông điệp: $message đến topic: $topic');
    } else {
      print('MQTT client chưa kết nối');
    }
  }

  //phần subscribe
 void subscribe(String topic, Function(String message) onMessage) {
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      // Đăng ký topic nếu chưa có
      if (!_topicCallbacks.containsKey(topic)) {
        client.subscribe(topic, MqttQos.atMostOnce);
        _topicCallbacks[topic] = onMessage; // Lưu callback cho topic

        print('Đã subscribe vào topic: $topic');
      } else {
        print('Topic đã được subscribe trước đó: $topic');
      }

      // Lắng nghe tin nhắn từ broker
      client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
        for (var message in messages) {
          final topicReceived = message.topic; // Khi nhận tin nhắn, kiểm tra topic nhận được
          final payload = message.payload as MqttPublishMessage;
          final messageString = MqttPublishPayload.bytesToStringAsString(payload.payload.message);

          print('Nhận tin nhắn: $messageString từ topic: $topicReceived');

          // Kiểm tra callback theo topic và gọi callback
          if (_topicCallbacks.containsKey(topicReceived)) {
            _topicCallbacks[topicReceived]!(messageString); // Gọi callback của topic nhận được
          } else {
            print('Không có callback xử lý cho topic: $topicReceived');
          }
        }
      });
    } else {
      print('Không thể subscribe, chưa kết nối với MQTT.');
    }
  }

  void unsubscribe(String topic) {
    if (_topicCallbacks.containsKey(topic)) {
      client.unsubscribe(topic);
      _topicCallbacks.remove(topic);
      print('Đã hủy subscribe topic: $topic');
    } else {
      print('Không tìm thấy topic để hủy: $topic');
    }
  }
}