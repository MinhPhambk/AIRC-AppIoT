import 'package:flutter/material.dart';

class FanModeControl extends StatefulWidget {
  final ValueChanged<int>? onModeChanged; // Callback khi chế độ thay đổi
  final Stream<int>? fanModeStream; // Stream để cập nhật chế độ từ MQTT

  const FanModeControl({super.key, this.onModeChanged, this.fanModeStream});

  @override
  State<FanModeControl> createState() => _FanModeControlState();
}

class _FanModeControlState extends State<FanModeControl> {
  int _selectedMode = 0; // Chế độ mặc định (0 = OFF)

  @override
  void initState() {
    super.initState();
    // Lắng nghe các thay đổi từ MQTT qua Stream
    widget.fanModeStream?.listen((newMode) {
      setState(() {
        _selectedMode = newMode; // Cập nhật chế độ từ MQTT
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildModeButton('OFF', 0, Colors.red, const BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        )),
        _buildModeButton('1', 1, Colors.green, BorderRadius.zero),
        _buildModeButton('2', 2, Colors.green, BorderRadius.zero),
        _buildModeButton('3', 3, Colors.green, const BorderRadius.only(
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
        )),
      ],
    );
  }

  Widget _buildModeButton(
      String label, int mode, Color activeColor, BorderRadius borderRadius) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMode = mode; // Cập nhật chế độ
        });

        // Gọi callback khi chế độ thay đổi
        if (widget.onModeChanged != null) {
          widget.onModeChanged!(mode);
        }
        print('Fan mode selected: $label');
      },
      child: Container(
        width: 30,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _selectedMode == mode ? activeColor : Colors.white,
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: borderRadius,
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}