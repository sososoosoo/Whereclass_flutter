import 'package:flutter/material.dart';
import 'package:whc_proto/widgets/api_svg_widget.dart';
import 'package:whc_proto/services/api_service.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  String selectedBuilding = '백운관';
  String selectedFloor = '1';

  final List<String> buildings = [
    '백운관',
    '컨버젼스 홀',
    '창조관',
    '청송관',
    '미래관',
    '정의관',
  ];

  final List<String> floors = ['1', '2', '3', '4', '5'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API 테스트'),
        backgroundColor: const Color(0xFF00AEFF),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 컨트롤 패널
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'API 백엔드 연결 테스트',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('건물 선택:'),
                          DropdownButton<String>(
                            value: selectedBuilding,
                            isExpanded: true,
                            items: buildings.map((building) {
                              return DropdownMenuItem(
                                value: building,
                                child: Text(building),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedBuilding = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('층 선택:'),
                          DropdownButton<String>(
                            value: selectedFloor,
                            isExpanded: true,
                            items: floors.map((floor) {
                              return DropdownMenuItem(
                                value: floor,
                                child: Text('${floor}층'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedFloor = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _testApiConnection,
                      child: const Text('API 연결 테스트'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // 강제 리빌드로 SVG 위젯 새로고침
                        });
                      },
                      child: const Text('새로고침'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // SVG 표시 영역
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: ApiSvgWidget(
                buildingName: selectedBuilding,
                floorNum: selectedFloor,
                onSvgElementTap: (svgId, itemInfo) {
                  _showRoomInfo(svgId, itemInfo);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _testApiConnection() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('API 연결 테스트 중...'),
            ],
          ),
        ),
      );

      // 건물 목록 가져오기 테스트
      final buildings = await ApiService.getAvailableBuildings();

      // 특정 건물의 층 목록 가져오기 테스트
      final buildingId = ApiService.getBuildingId(selectedBuilding);
      final floors = await ApiService.getAvailableFloors(buildingId);

      // 건물 데이터 가져오기 테스트
      final buildingData = await ApiService.getBuildingData(buildingId);

      Navigator.of(context).pop(); // 로딩 다이얼로그 닫기

      // 결과 표시
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('API 테스트 결과'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🏢 건물 목록 (${buildings.length}개):'),
                Text(buildings.join(', ')),
                const SizedBox(height: 16),
                Text('🏢 $selectedBuilding 층 목록 (${floors.length}개):'),
                Text(floors.join(', ')),
                const SizedBox(height: 16),
                Text('📊 건물 데이터:'),
                Text(buildingData != null ? '✅ 성공' : '❌ 실패'),
                if (buildingData != null)
                  Text('Building ID: ${buildingData['id']}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // 로딩 다이얼로그 닫기

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('API 연결 실패'),
          content: Text('오류: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  void _showRoomInfo(String svgId, Map<String, dynamic> itemInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('강의실 정보'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ID: $svgId'),
            Text('이름: ${itemInfo['display_name'] ?? 'N/A'}'),
            Text('타입: ${itemInfo['type'] ?? 'N/A'}'),
            const SizedBox(height: 8),
            const Text('🎉 클릭 이벤트가 정상 작동합니다!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}