import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Component/sensor_chart.dart';

class FirebaseService {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // Lấy dữ liệu từ collection bất kỳ
  Stream<List<SensorData>> getSensorDataStream(String collectionName) {
    return _fireStore.collection(collectionName).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return SensorData.fromFirestore(doc.data());
      }).toList();
    });
  }
}