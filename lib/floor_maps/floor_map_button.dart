import 'package:flutter/material.dart';
import 'package:whc_proto/methods/current_location.dart';
import 'package:whc_proto/methods/screen_controller.dart';

class FloorMapButton extends StatelessWidget {
  const FloorMapButton({
    required this.buildingName, 
    required this.floorNum, 
    required this.currentFloor,
    super.key
  });

  final String buildingName;
  final String floorNum;
  final String currentFloor;

  @override
  Widget build(BuildContext context) {
    // 현재 층수인지 확인
    bool isCurrentFloor = floorNum == currentFloor;
    
    // 층수 표시 형식 변경: B1은 그대로, 나머지는 숫자F 형식
    String displayFloor = floorNum == 'B1' ? floorNum : '${floorNum}F';
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isCurrentFloor ? Colors.blue : Colors.white,
          foregroundColor: isCurrentFloor ? Colors.white : Colors.grey[700],
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(75, 45),
        ),
        onPressed: () {
          ScreenController.current.value = AppScreen.map;
          currentLocation.value = CurrentLocation(
              curBuildingName: buildingName, curFloorNum: floorNum);
        },
        child: Text(
          displayFloor,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isCurrentFloor ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
