import 'package:apptaodanhmuc/Component/custom_switch.dart';
import 'package:apptaodanhmuc/Component/custom_toggle_button.dart';
import 'package:apptaodanhmuc/Component/fan_mode_control.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Items extends StatelessWidget {
  final String title;
  final Future<void> Function(BuildContext, String)? onEdit;
  final VoidCallback? onDelete;
  final Function(String, bool)? onToggle;
  final bool? initialSwitchState; // Trạng thái ban đầu
  final Function(String, int)? onFanModeChanged; // Callback xử lý chế độ quạt
  final Stream<int>? fanModeStream; // Stream để đồng bộ chế độ quạt

  const Items({
    super.key,
    required this.title,
    this.onEdit,
    this.onDelete,
    required BuildContext context,
    this.onToggle, this.onFanModeChanged, this.initialSwitchState, this.fanModeStream,
  });

  @override
  Widget build(BuildContext context) {
    bool switchState = initialSwitchState ?? false;
    // Tách tên thiết bị từ title (giả sử title luôn có dạng "Tên Thiết Bị X")
    String deviceName = title.split(' ')[0]; // Lấy phần tên thiết bị (trước dấu cách)

    // Điều kiện để xác định icon tùy thuộc vào tên thiết bị
    IconData deviceIcon;
    if (deviceName == 'LED') {
      deviceIcon = Icons.lightbulb_outline; // Icon cho LED
    } else if (deviceName == 'FAN') {
      deviceIcon = FontAwesomeIcons.fan; // Icon cho FAN
    } else if (deviceName == 'AIR') {
      deviceIcon = Icons.ac_unit_outlined;
    } else {
      deviceIcon = Icons.important_devices; // Icon mặc định
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 5, 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Flexible(
            child: Padding(
              padding: deviceName=='FAN'
              ? const EdgeInsets.fromLTRB(5, 20, 0, 8)
              : deviceName == 'AIR'
              ? const EdgeInsets.fromLTRB(5, 8, 0, 40)
              : const EdgeInsets.fromLTRB(15, 30, 0, 30),
              child: Column(
                children: [
                  Icon(deviceIcon, size: 70),
                  if (deviceName != 'FAN'|| deviceName != 'AIR') const Spacer(),
                  SizedBox(
                    width: 90, // Chiều rộng cố định cho text
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center, // Căn giữa text
                    ),
                  ),
                  if(deviceName == "FAN")...[
                    FanModeControl(
                      fanModeStream: fanModeStream, // Stream để cập nhật chế độ
                      onModeChanged: (int mode) {
                        if(onFanModeChanged != null){
                          onFanModeChanged!(title, mode); // Gọi hàm xử lý quạt
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(
              width: deviceName == 'FAN'? 0 : 10
          ),
          Padding(
            padding: deviceName == 'LED'
            ? const EdgeInsets.fromLTRB(0, 8, 10, 8)
            : deviceName == 'FAN'
            ? const EdgeInsets.fromLTRB(1, 20, 0, 0)
            : deviceName == 'AIR'
            ? const EdgeInsets.fromLTRB(0, 7, 6, 8)
            : const EdgeInsets.fromLTRB(10, 30, 0, 30),
            child: Column(
              children: [
                if(deviceName=='LED')...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                    child: CustomSwitch(
                      initialValue: switchState, // Cập nhật từ bên ngoài
                        onChanged: (value) {
                        // Xử lý thay đổi trạng thái của đèn
                          if (onToggle != null) {
                            onToggle!(title, value);
                          }
                        },),
                  )],
                if(deviceName=='AIR')...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: CustomToggleButton(
                      initialState: false,
                        onChanged:(value) {},
                      activeText: 'ON',
                      inactiveText: 'OFF',
                      activeColor: Colors.green,
                      inactiveColor: Colors.red.shade700,
                    ),
                  ),
                  ],
                IconButton(
                  onPressed: () {
                    if (onEdit != null) {
                      onEdit!(context, title); // Gọi hàm chỉnh sửa tên
                    }
                  },
                  icon: const Icon(Icons.edit, size: 35, color: Colors.black),
                ),
                if (deviceName != 'FAN'|| deviceName != 'AIR') const Spacer(),
                IconButton(
                  onPressed: () {
                    if (onDelete != null) {
                      onDelete!(); // Gọi hàm xóa
                    }
                  },
                  icon: const Icon(Icons.delete_outline, size: 35, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}