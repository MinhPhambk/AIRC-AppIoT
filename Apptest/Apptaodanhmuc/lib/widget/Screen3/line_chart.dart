import 'package:flutter/material.dart';
import '../../Component/sensor_chart.dart';
import '../../Controller/Cloud_Firestore/firebase_service.dart';

class LineChart extends StatefulWidget {
  const LineChart({super.key, required this.deviceName});
  final String deviceName;

  @override
  State<LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF33CCFF),
        title: const Text(
          'Sensor Data Charts',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<List<SensorData>>(
              stream: _firebaseService.getSensorDataStream('homeData'),
              builder: (context, homeSnapshot) {
                return StreamBuilder<List<SensorData>>(
                  stream: _firebaseService.getSensorDataStream('outdoorData'),
                  builder: (context, outdoorSnapshot) {
                    if (homeSnapshot.connectionState == ConnectionState.waiting ||
                        outdoorSnapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (homeSnapshot.hasError || outdoorSnapshot.hasError) {
                      return Text('Error: ${homeSnapshot.error ?? outdoorSnapshot.error}');
                    }
                    if (!homeSnapshot.hasData || !outdoorSnapshot.hasData) {
                      return const Text('No data available');
                    }

                    final homeData = homeSnapshot.data!;
                    final outdoorData = outdoorSnapshot.data!;

                    return Column(
                      children: [
                        buildChartContainer(
                          SensorChart(
                            sensorName: 'Temperature Sensor',
                            homeData: homeData,
                            outdoorData: outdoorData,
                            yValueMapperHome: (SensorData data, _) => data.temperature,
                            yValueMapperOutdoor: (SensorData data, _) => data.temperature,
                            unit: '°C',
                            yMin: 10,
                            yMax: 100,
                          ),
                        ),
                        buildChartContainer(
                          SensorChart(
                            sensorName: 'Humidity Sensor',
                            homeData: homeData,
                            outdoorData: outdoorData,
                            yValueMapperHome: (SensorData data, _) => data.humidity,
                            yValueMapperOutdoor: (SensorData data, _) => data.humidity,
                            unit: '%',
                            yMin: 10,
                            yMax: 100,
                          ),
                        ),
                        buildChartContainer(
                          SensorChart(
                            sensorName: 'Pressure Sensor',
                            homeData: homeData,
                            outdoorData: outdoorData,
                            yValueMapperHome: (SensorData data, _) => data.pressure,
                            yValueMapperOutdoor: (SensorData data, _) => data.pressure,
                            unit: 'hPa',
                            yMin: 1000,
                            yMax: 1200,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildChartContainer(Widget child) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.5 * 255).toInt()),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}