import 'package:flutter/material.dart';
import 'package:whc_proto/methods/screen_controller.dart';
import 'package:whc_proto/methods/current_location.dart';

class MapAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MapAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    String data = currentLocation.value.curBuildingName.isNotEmpty
        ? currentLocation.value.curBuildingName
        : 'Map';

    return AppBar(
      leading: IconButton(
        onPressed: () {
          ScreenController.current.value = AppScreen.main;
        },
        icon: Icon(Icons.arrow_back),
      ),
      title: Stack(
        alignment: Alignment.center,
        children: [
          Text(data, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          child: IconButton(
            onPressed: () {
              // 검색 화면으로 이동
              ScreenController.current.value = AppScreen.search;
            },
            icon: const Icon(
              Icons.search,
              color: Colors.grey,
              size: 28,
            ),
            iconSize: 28,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),
        ),
      ],
    );
  }
}
