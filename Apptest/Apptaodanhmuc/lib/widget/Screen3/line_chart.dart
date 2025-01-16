import 'package:flutter/material.dart';
import '../../Component/sensor_chart.dart';
import '../../Controller/Cloud_MongoDB/MongoDB_service.dart';
import '../../Controller/Cloud_MongoDB/sensor_data.dart';

class LineChart extends StatefulWidget {
  const LineChart({super.key, required this.deviceName});
  final String deviceName;

  @override
  State<LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {
  final MongoDBService _mongoDBService = MongoDBService();
  List<SensorData> _sensorData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  void _initializeStream() {
    _mongoDBService.getDynamicSensorData().listen((data) {
      setState(() {
        _sensorData = data;
        _isLoading = false;
      });
    });
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sensorData.isEmpty
          ? const Center(child: Text('No data available'))
          : SingleChildScrollView(
        child: Column(
          children: [
            buildChartContainer(
              SensorChart(
                sensorName: 'Temperature Sensor',
                sensorData: _sensorData,
                yValueMapper: (SensorData data, _) => data.temp,
                unit: '°C',
                // yMin: 10,
                // yMax: 30,
                lineColor: Colors.redAccent,
              ),
            ),
            buildChartContainer(
              SensorChart(
                sensorName: 'Humidity Sensor',
                sensorData: _sensorData,
                yValueMapper: (SensorData data, _) => data.humi,
                unit: '%',
                // yMin: 10,
                // yMax: 100,
                lineColor: Colors.blueAccent,
              ),
            ),
            buildChartContainer(
              SensorChart(
                sensorName: 'Lux Sensor',
                sensorData: _sensorData,
                yValueMapper: (SensorData data, _) => data.lux,
                unit: 'Lx',
                // yMin: 100,
                // yMax: 500,
                lineColor: Colors.lime[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildChartContainer(Widget child) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      padding: const EdgeInsets.all(10),
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