import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SensorChart extends StatelessWidget {
  final String sensorName;
  final List<SensorData> homeData;
  final List<SensorData> outdoorData;
  final ChartValueMapper<SensorData, num> yValueMapperHome;
  final ChartValueMapper<SensorData, num> yValueMapperOutdoor;
  final String unit;  // Thêm biến đơn vị
  final Color? lineColor;
  final Color? xAxisColor; // Màu sắc của trục X
  final Color? yAxisColor; // Màu sắc của trục Y
  final String? xMin;  // Giá trị tối thiểu của trục X
  final String? xMax;  // Giá trị tối đa của trục X
  final double yMin;  // Giá trị tối thiểu của trục Y
  final double yMax;  // Giá trị tối đa của trục Y

  const SensorChart({
    super.key,
    required this.sensorName,
    required this.homeData,required this.outdoorData,

    required this.yValueMapperHome,
    required this.yValueMapperOutdoor,

    required this.unit,
    this.lineColor, this.xAxisColor, this.yAxisColor,
    this.xMin, this.xMax, required this.yMin, required this.yMax,
  });

  @override
  Widget build(BuildContext context) {
    final tooltipBehavior = TooltipBehavior(enable: true);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: SingleChildScrollView(
        //scrollDirection: Axis.horizontal, // Cho phép cuộn ngang
        child: SfCartesianChart(
          title: ChartTitle(
              text: '$sensorName ($unit)',alignment: ChartAlignment.center,
              textStyle: const TextStyle(fontWeight: FontWeight.w500)),
          tooltipBehavior: tooltipBehavior,
          series: <CartesianSeries>[
            LineSeries<SensorData, String>(
              dataSource: homeData,
              xValueMapper: (SensorData data, _) => data.time,
              yValueMapper: yValueMapperHome,
              name: 'Home',
              color: Colors.blueAccent,
              markerSettings: const MarkerSettings(isVisible: true),
            ),
            LineSeries<SensorData, String>(
              dataSource: outdoorData,
              xValueMapper: (SensorData data, _) => data.time,
              yValueMapper: yValueMapperOutdoor,
              name: 'OutDoor',
              color: Colors.redAccent,
              markerSettings: const MarkerSettings(isVisible: true),
            ),
          ],
          legend: const Legend(
              isVisible: true,
            position: LegendPosition.bottom,
          ),
          primaryXAxis: const CategoryAxis(
            labelRotation: 45, // Góc xoay chữ trên trục X
            //majorGridLines: MajorGridLines(color: Colors.black), // Tắt các đường lưới chính
            axisLine: AxisLine(
              color: Colors.black,
              //width: 0, // Đặt độ dày của trục X
            ),
            //labelStyle: TextStyle(color: xAxisColor), // Đặt màu sắc chữ trục X
          ),
          primaryYAxis: CategoryAxis(
            //majorGridLines: MajorGridLines(color: Colors.black),
            axisLine: const AxisLine(
                color: Colors.black
            ),
            //labelStyle: TextStyle(color: yAxisColor), // Đặt màu sắc chữ trục Y
            minimum: yMin,
            maximum: yMax,
          ),
        ),
      ),
    );
  }
}

class SensorData {
  final String time;
  final num temperature;
  final num humidity;
  final num pressure;

  SensorData({
    required this.time,
    required this.temperature,
    required this.humidity,
    required this.pressure,
  });

  factory SensorData.fromFirestore(Map<String, dynamic> json) {
    return SensorData(
      time: json['time'] ?? '',
      temperature: json['temperature'] ?? 0,
      humidity: json['humidity'] ?? 0,
      pressure: json['pressure'] ?? 0,
    );
  }
}