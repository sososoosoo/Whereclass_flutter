import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:whc_proto/services/api_service.dart';
import 'package:whc_proto/widgets/polygon_tap_area.dart';
import 'package:whc_proto/widgets/room_info_modal.dart';
import 'package:whc_proto/screens/interactive_svg_screen.dart'; // RoomData 클래스 import
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ApiInteractiveSvgScreen extends StatefulWidget {
  final String buildingName;
  final String floorName;

  const ApiInteractiveSvgScreen({
    Key? key,
    required this.buildingName,
    required this.floorName,
  }) : super(key: key);

  @override
  State<ApiInteractiveSvgScreen> createState() => _ApiInteractiveSvgScreenState();
}

class _ApiInteractiveSvgScreenState extends State<ApiInteractiveSvgScreen> {
  Map<String, dynamic>? svgData;
  Map<String, dynamic>? currentFloorData;
  String? svgContent;
  bool isLoading = false;
  String? selectedRoomId;
  late TransformationController _transformationController;
  List<Map<String, dynamic>>? selectedRoomPolygon;
  bool _isModalVisible = true;
  List<dynamic>? _roomShapes;
  String? _errorMessage;
  RoomData? _selectedRoomData;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _loadSvgAndRoomData();
  }

  @override
  void didUpdateWidget(ApiInteractiveSvgScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.buildingName != widget.buildingName ||
        oldWidget.floorName != widget.floorName) {
      _loadSvgAndRoomData();
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _loadSvgAndRoomData() async {
    setState(() {
      isLoading = true;
      _errorMessage = null;
      selectedRoomId = null;
      selectedRoomPolygon = null;
    });

    try {
      // Extract building ID and floor number from floorName
      // floorName format: "convergence_hall_floor_B1"
      final parts = widget.floorName.split('_');
      final buildingId = widget.buildingName;
      final floorNum = parts.length >= 4 ? parts.last : '1';

      debugPrint('API Interactive SVG - Building: $buildingId, Floor: $floorNum');

      // Try to get data from API
      final apiResponse = await ApiService.getSvgData(buildingId, widget.floorName);

      // Load room shapes and SVG from local JSON
      try {
        final assetPath = 'assets/output_json/flutter_svg_data.json';
        final jsonStr = await rootBundle.loadString(assetPath);
        final fullData = json.decode(jsonStr) as Map<String, dynamic>;

        final buildingsData = fullData['buildings'] as Map<String, dynamic>;
        final buildingData = buildingsData[buildingId] as Map<String, dynamic>?;

        if (buildingData != null) {
          final floorsData = buildingData['floors'] as Map<String, dynamic>;
          final floorData = floorsData[widget.floorName] as Map<String, dynamic>?;

          if (floorData != null) {
            currentFloorData = floorData;

            // Extract clickable areas and convert to proper format
            final clickableAreas = floorData['clickable_areas'] as Map<String, dynamic>? ?? {};
            _roomShapes = [];

            clickableAreas.forEach((key, value) {
              final room = value as Map<String, dynamic>;
              final roomId = room['id'] as String?;
              final displayName = room['display_name'] as String?;
              final polygon = room['polygon'] as List?;

              if (roomId != null && polygon != null && polygon.isNotEmpty) {
                // Convert polygon coordinates to proper format
                final List<List<double>> points = [];
                for (var point in polygon) {
                  if (point is Map<String, dynamic>) {
                    final x = point['x']?.toDouble();
                    final y = point['y']?.toDouble();
                    if (x != null && y != null) {
                      points.add([x, y]);
                    }
                  }
                }

                if (points.isNotEmpty) {
                  _roomShapes!.add({
                    'id': roomId,
                    'display_name': displayName ?? roomId,
                    'shapes': [
                      {
                        'type': 'polygon',
                        'points': points,
                      }
                    ]
                  });
                }
              }
            });

            debugPrint('Loaded ${_roomShapes!.length} clickable rooms for ${widget.floorName}');

            // Load SVG file from web server
            try {
              // Debug: Print what we're working with
              debugPrint('Building ID: $buildingId');
              debugPrint('Floor Name: ${widget.floorName}');
              debugPrint('Floor Number: $floorNum');

              // Construct SVG URL for web server
              final svgFileName = '${buildingId}_floor_${floorNum}.svg';
              final svgUrl = '/svg/$buildingId/$svgFileName';
              debugPrint('HTTP SVG 로드 시도: $svgUrl');

              // Load SVG via HTTP
              final response = await http.get(Uri.parse(svgUrl));
              if (response.statusCode == 200) {
                svgContent = response.body;
                debugPrint('SVG 로드 성공: ${svgContent!.length} characters');
              } else {
                throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
              }
            } catch (e) {
              debugPrint('SVG 파일 로드 실패: $e');
              // Fallback to placeholder SVG
              svgContent = '''
                <svg width="1000" height="800" viewBox="0 0 1000 800" xmlns="http://www.w3.org/2000/svg">
                  <rect width="1000" height="800" fill="#f9f9f9" stroke="#ddd" stroke-width="2"/>
                  <text x="500" y="380" text-anchor="middle" fill="#333" font-size="24" font-weight="bold">
                    ${buildingId.replaceAll('_', ' ').toUpperCase()} - ${floorNum}층
                  </text>
                  <text x="500" y="410" text-anchor="middle" fill="#666" font-size="16">
                    API 연결: ${apiResponse != null ? '성공 ✓' : '연결중...'}
                  </text>
                  <text x="500" y="430" text-anchor="middle" fill="#666" font-size="14">
                    클릭 가능한 방: ${_roomShapes?.length ?? 0}개
                  </text>
                  <text x="500" y="460" text-anchor="middle" fill="#e74c3c" font-size="12">
                    SVG 파일 로드 실패: $e
                  </text>
                </svg>
              ''';
            }
          }
        }
      } catch (e) {
        debugPrint('JSON 로드 오류: $e');
        _roomShapes = null;
        svgContent = '''
          <svg width="1000" height="800" viewBox="0 0 1000 800" xmlns="http://www.w3.org/2000/svg">
            <rect width="1000" height="800" fill="#fff" stroke="#ddd" stroke-width="2"/>
            <text x="500" y="400" text-anchor="middle" fill="#999" font-size="20">
              데이터 로드 중...
            </text>
          </svg>
        ''';
      }

      if (mounted) {
        setState(() {
          isLoading = false;
          if (svgContent == null) {
            _errorMessage = 'SVG 데이터를 찾을 수 없습니다.';
          }
        });
      }
    } catch (e) {
      debugPrint('API SVG 로드 오류: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'API SVG 로드 실패: $e';
          isLoading = false;
        });
      }
    }
  }

  void _onRoomTap(String roomId, Map<String, dynamic> roomInfo) {
    debugPrint('Room tapped: $roomId');

    // RoomData 객체 생성
    String buildingName = _getBuildingDisplayName(widget.buildingName);
    String roomNumber = roomId.split('_').last;
    String roomType = _getRoomType(roomId);

    RoomData roomData = RoomData(
      buildingNameEn: widget.buildingName,
      buildingNameKo: buildingName,
      floor: widget.floorName,
      notes: '',
      roomNameKo: roomType.isNotEmpty ? roomType : '강의실',
      roomNumber: roomNumber,
      roomType: roomType,
      searchKeywords: '',
      svgFilename: '',
      uniqueId: roomId,
    );

    setState(() {
      selectedRoomId = roomId;
      _selectedRoomData = roomData;
      _isModalVisible = true;
    });
  }

  void _hideModal() {
    setState(() {
      _isModalVisible = false;
    });
  }

  void _closeModal() {
    setState(() {
      selectedRoomId = null;
      _selectedRoomData = null;
      _isModalVisible = true;
    });
  }

  String _getRoomType(String roomId) {
    // Simple logic to determine room type based on room ID
    if (roomId.contains('휴게') || roomId.toLowerCase().contains('lounge')) {
      return '학생휴게실';
    } else if (roomId.contains('화장실') || roomId.toLowerCase().contains('toilet')) {
      return '화장실';
    } else if (roomId.contains('엘리베이터') || roomId.toLowerCase().contains('elevator')) {
      return '엘리베이터';
    } else if (roomId.contains('void') || roomId.contains('???')) {
      return '기타 공간';
    } else {
      return '강의실';
    }
  }

  String _getBuildingDisplayName(String buildingId) {
    switch (buildingId) {
      case 'convergence_hall':
        return '컨버전스홀';
      case 'baekun_hall':
        return '백운관';
      case 'changjo_hall':
        return '창조관';
      case 'cheongsong_hall':
        return '청송관';
      case 'mirae_hall':
        return '미래관';
      case 'jeongui_hall':
        return '정의관';
      default:
        return buildingId.replaceAll('_', ' ').toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('SVG 데이터 로드 중...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSvgAndRoomData,
              child: Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (svgContent == null) {
      return const Center(
        child: Text('SVG 데이터가 없습니다.'),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          InteractiveViewer(
        transformationController: _transformationController,
        boundaryMargin: EdgeInsets.zero,
        minScale: 0.5,
        maxScale: 3.0,
        panEnabled: false, // Disable pan/drag
        scaleEnabled: true, // Keep zoom
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // SVG 배경
              Container(
                width: double.infinity,
                height: double.infinity,
                child: SvgPicture.string(
                  svgContent!,
                  fit: BoxFit.contain,
                  placeholderBuilder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              // 클릭 가능한 영역들
              if (_roomShapes != null)
                ..._roomShapes!.expand((room) {
                  final id = room['id'];
                  final shapes = room['shapes'] as List?;
                  if (shapes == null) return <Widget>[];
                  return shapes.map<Widget>((shape) {
                    if (shape['type'] == 'polygon' && shape['points'] != null) {
                      final points = shape['points'] as List<dynamic>;

                      // Calculate bounding box for this polygon
                      double minX = double.infinity;
                      double minY = double.infinity;
                      double maxX = double.negativeInfinity;
                      double maxY = double.negativeInfinity;

                      for (var point in points) {
                        double x = point[0].toDouble();
                        double y = point[1].toDouble();
                        minX = minX < x ? minX : x;
                        minY = minY < y ? minY : y;
                        maxX = maxX > x ? maxX : x;
                        maxY = maxY > y ? maxY : y;
                      }

                      // For now, use a simple rectangular area for testing
                      return Positioned(
                        left: minX,
                        top: minY,
                        width: maxX - minX,
                        height: maxY - minY,
                        child: GestureDetector(
                          onTap: () {
                            debugPrint('Clicked on room: $id');
                            _onRoomTap(id, room);
                          },
                          child: Container(
                            color: selectedRoomId == id
                                ? Colors.blue.withOpacity(0.4)
                                : Colors.transparent, // Make it invisible
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  });
                }),
            ],
          ),
        ),
          ),
          // 모달
          RoomInfoModal(
            roomData: _selectedRoomData,
            isVisible: _isModalVisible,
            onHide: _hideModal,
            onClose: _closeModal,
          ),
        ],
      ),
    );
  }
}