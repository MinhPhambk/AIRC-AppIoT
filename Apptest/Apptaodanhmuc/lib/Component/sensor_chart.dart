import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../Controller/Cloud_MongoDB/sensor_data.dart';

class SensorChart extends StatelessWidget {
  final String sensorName;
  final List<SensorData> sensorData;
  //final List<SensorData> outdoorData;
  final ChartValueMapper<SensorData, num> yValueMapper;
  // final ChartValueMapper<SensorData, num> yValueMapperHome;
  //final ChartValueMapper<SensorData, num> yValueMapperOutdoor;
  final String unit;  // Thêm biến đơn vị
  final Color? lineColor;
  final Color? xAxisColor; // Màu sắc của trục X
  final Color? yAxisColor; // Màu sắc của trục Y
  final String? xMin;  // Giá trị tối thiểu của trục X
  final String? xMax;  // Giá trị tối đa của trục X
  final double? yMin;  // Giá trị tối thiểu của trục Y
  final double? yMax;  // Giá trị tối đa của trục Y

  const SensorChart({
    super.key,
    required this.sensorName,
    required this.sensorData, required this.yValueMapper,
    required this.unit,
    this.lineColor, this.xAxisColor, this.yAxisColor,
    this.xMin, this.xMax, this.yMin, this.yMax,
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
              dataSource: sensorData,
              xValueMapper: (SensorData data, _) => data.time,
              yValueMapper: yValueMapper,
              name: sensorName,
              color: lineColor,
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
          primaryYAxis: NumericAxis(
            //majorGridLines: MajorGridLines(color: Colors.black),
            axisLine: const AxisLine(
                color: Colors.black
            ),
            axisLabelFormatter: (AxisLabelRenderDetails details) {
              final value = details.value; // Lấy giá trị từ trục
              final formattedValue = value.toStringAsFixed(2); // Làm tròn đến 2 chữ số thập phân
              return ChartAxisLabel(formattedValue, const TextStyle(color: Colors.black));
            },
            //labelStyle: TextStyle(color: yAxisColor), // Đặt màu sắc chữ trục Y
            // minimum: yMin,
            // maximum: yMax,
          ),
        ),
      ),
    );
  }
}