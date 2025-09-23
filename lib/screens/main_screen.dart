import 'package:flutter/material.dart';
import 'package:whc_proto/building_class.dart';
import 'package:whc_proto/methods/create_main_building_button.dart';
import 'package:whc_proto/methods/screen_controller.dart';
import 'package:whc_proto/screens/api_test_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // 검색바 - 이미지 스타일로 수정
            Container(
              margin: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () {
                  ScreenController.current.value = AppScreen.search;
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.blue, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey, size: 20),
                      SizedBox(width: 12),
                      Text(
                        '어디수업이세요?',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // API 테스트 버튼 추가
            Container(
              margin: const EdgeInsets.all(16.0),
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ApiTestScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.api, color: Colors.white),
                label: const Text(
                  '🚀 API 백엔드 테스트 (Firebase → Spring Boot)',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // 기존 건물 버튼들 유지
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  for (var building in allBuildings) ...{
                    CreateMainBuildingButton(buildingId: building.id),
                  },
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
