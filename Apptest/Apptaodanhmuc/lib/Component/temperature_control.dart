import 'package:flutter/material.dart';

class TemperatureControl extends StatefulWidget {
  final int initialTemperature;
  final ValueChanged<int> onChanged;

  const TemperatureControl({
    super.key,
    this.initialTemperature = 24,
    required this.onChanged,
  });

  @override
  State<TemperatureControl> createState() => _TemperatureControlState();
}

class _TemperatureControlState extends State<TemperatureControl> {
  late int _currentTemperature;

  @override
  void initState() {
    super.initState();
    _currentTemperature = widget.initialTemperature;
  }

  void _increaseTemperature() {
    if (_currentTemperature < 30) {
      setState(() {
        _currentTemperature++;
      });
      widget.onChanged(_currentTemperature);
    }
  }

  void _decreaseTemperature() {
    if (_currentTemperature > 18) {
      setState(() {
        _currentTemperature--;
      });
      widget.onChanged(_currentTemperature);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2,),
      constraints: const BoxConstraints(maxWidth: 100,
        maxHeight: 30,),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((255 * 0.3).toInt()),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Nút giảm
          IconButton(
            onPressed: _decreaseTemperature,
            icon: const Icon(Icons.remove),
            color: Colors.blue,
            iconSize: 13,
          ),
          //const SizedBox(width: 10),
          // Nhiệt độ hiển thị
          Text(
            '$_currentTemperature°C',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          //const SizedBox(width: 10),
          // Nút tăng
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: IconButton(
              onPressed: _increaseTemperature,
              icon: const Icon(Icons.add),
              color: Colors.blue,
              iconSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
