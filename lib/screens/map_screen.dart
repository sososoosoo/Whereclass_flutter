import 'package:flutter/material.dart';

import 'package:whc_proto/floor_maps/floor_map_button.dart';
import 'package:whc_proto/methods/current_location.dart';
import 'package:whc_proto/building_class.dart';
import 'package:whc_proto/screens/api_interactive_svg_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CurrentLocation>(
      valueListenable: currentLocation,
      builder: (context, loc, child) {
        String buildingId = getBuildingId(loc.curBuildingName);

        BuildingClass? building = allBuildings.firstWhere(
          (b) => b.id == buildingId,
          orElse: () => BuildingClass(
              name: 'Unknown',
              id: 'unknown',
              info: 'No information available',
              floors: []),
        );

        final floors = building.floors;

        return Align(
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 16.0),
              
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                child: Row(
                  children: [
                    for (var floorInd in floors) ...[
                      FloorMapButton(
                        floorNum: floorInd,
                        buildingName: loc.curBuildingName,
                        currentFloor: loc.curFloorNum, // 현재 층수 전달
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              Expanded(
                // ApiInteractiveSvgScreen의 핵심 위젯 사용
                child: ApiInteractiveSvgScreen(
                  key: ValueKey(
                      '${getBuildingId(loc.curBuildingName)}_${loc.curFloorNum}'),
                  buildingName: getBuildingId(loc.curBuildingName),
                  floorName:
                      '${getBuildingId(loc.curBuildingName)}_floor_${loc.curFloorNum}',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
