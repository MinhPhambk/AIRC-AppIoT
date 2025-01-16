class SensorData {
  final int? index;
  final String time;
  final num temp;
  final num humi;
  final num lux;

  SensorData({
    this.index,
    required this.time,
    required this.temp,
    required this.humi,
    required this.lux,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      index: json['index'] as int?,
      time: json['time'] ?? '',
      temp: json['temp'] ?? 0,
      humi: json['humi'] ?? 0,
      lux: json['lux'] ?? 0,
    );
  }
}
