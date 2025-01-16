import 'dart:async';
import 'package:apptaodanhmuc/Controller/Cloud_MongoDB/sensor_data.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoDBService {
  static late Db _db;
  static late DbCollection _collection;
  List<SensorData>? _previousData;

  // Hàm khởi tạo MongoDB
  static Future<void> init() async {
    try {
      _db = await Db.create('mongodb+srv://test:test@cluster0.djrgr.mongodb.net/');
      await _db.open();
      _collection = _db.collection('sensorData');
      print('Connected to MongoDB!');
    } catch (e) {
      print('Error connecting to MongoDB: $e');
      rethrow;
    }
  }

  // Hàm lấy dữ liệu động (5 bản ghi cuối)
  Stream<List<SensorData>> getDynamicSensorData() async* {
    try {
      while (true) {
        final data = await _collection
            .find(where.sortBy('index', descending: true).limit(5))
            .toList();

        final currentData = data.map((json) => SensorData.fromJson(json)).toList();

        // Phát `Stream` chỉ khi dữ liệu thay đổi
        if (_previousData == null || !_areListsEqual(_previousData!, currentData)) {
          _previousData = currentData;
          yield currentData;
        }

        // Đợi 2 giây trước khi kiểm tra cập nhật mới
        await Future.delayed(const Duration(seconds: 2));
      }
    } catch (e) {
      print('Error fetching sensor data: $e');
      rethrow;
    }
  }

  // Hàm đóng kết nối MongoDB
  Future<void> close() async {
    try {
      await _db.close();
      print('MongoDB connection closed.');
    } catch (e) {
      print('Error closing MongoDB connection: $e');
    }
  }

  // Hàm so sánh hai danh sách
  bool _areListsEqual(List<SensorData> a, List<SensorData> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].index != b[i].index ||
          a[i].temp != b[i].temp ||
          a[i].humi != b[i].humi ||
          a[i].lux != b[i].lux) {
        return false;
      }
    }
    return true;
  }
}