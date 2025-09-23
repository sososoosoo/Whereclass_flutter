import 'package:flutter/material.dart';
import 'package:whc_proto/building_class.dart';
import 'package:whc_proto/methods/current_location.dart';
import 'package:whc_proto/methods/screen_controller.dart';

class FloorButton extends StatelessWidget {
  const FloorButton(
      {super.key, required this.floorNum, required this.buildingId});

  final String floorNum;
  final String buildingId;

  @override
  Widget build(BuildContext context) {
    String buildingName = getBuildingName(buildingId);
    
    // 층수 표시 형식 변경: B1은 그대로, 나머지는 숫자F 형식
    String displayFloor = floorNum == 'B1' ? floorNum : '${floorNum}F';

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[700],
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 17.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0), // 둥근 모서리 제거
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(0, 32),
      ),
      onPressed: () {
        ScreenController.current.value = AppScreen.map;
        currentLocation.value.updateLocation(
            curBuildingName: buildingName, curFloorNum: floorNum);
      },
      child: Text(
        displayFloor,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF3385FF),
        ),
      ),
    );
  }
}
