import 'package:flutter/material.dart';

class CustomToggleButton extends StatefulWidget {
  final bool initialState;
  final ValueChanged<bool> onChanged;
  final String activeText;
  final String inactiveText;
  final Color activeColor;
  final Color inactiveColor;

  const CustomToggleButton({
    super.key,
    this.initialState = false,
    required this.onChanged,
    this.activeText = 'ON',
    this.inactiveText = 'OFF',
    this.activeColor = Colors.green,
    this.inactiveColor = Colors.red,
  });

  @override
  State<CustomToggleButton> createState() => _CustomToggleButtonState();
}

class _CustomToggleButtonState extends State<CustomToggleButton> {
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _isActive = widget.initialState;
  }

  void _toggleButton() {
    setState(() {
      _isActive = !_isActive;
    });
    widget.onChanged(_isActive);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleButton,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 60,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _isActive ? widget.activeColor : widget.inactiveColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          _isActive ? widget.activeText : widget.inactiveText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
