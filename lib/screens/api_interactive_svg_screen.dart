import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:whc_proto/services/api_service.dart';
import 'package:whc_proto/widgets/polygon_tap_area.dart';

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

            // Extract clickable areas and convert to list format
            final clickableAreas =
                floorData['clickable_areas'] as Map<String, dynamic>? ?? {};
            _roomShapes = clickableAreas.values.toList();

            // Create a simple SVG for now (until we have actual SVG files served from API)
            svgContent = '''
              <svg width="1000" height="800" viewBox="0 0 1000 800" xmlns="http://www.w3.org/2000/svg">
                <rect width="1000" height="800" fill="#f9f9f9" stroke="#ddd" stroke-width="2"/>
                <text x="500" y="400" text-anchor="middle" fill="#333" font-size="24" font-weight="bold">
                  ${buildingId.replaceAll('_', ' ').toUpperCase()} - ${floorNum}층
                </text>
                <text x="500" y="430" text-anchor="middle" fill="#666" font-size="16">
                  API 연결: ${apiResponse != null ? '성공 ✓' : '연결중...'}
                </text>
                <text x="500" y="450" text-anchor="middle" fill="#666" font-size="14">
                  클릭 가능한 방: ${_roomShapes?.length ?? 0}개
                </text>
              </svg>
            ''';
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
    setState(() {
      selectedRoomId = roomId;
      _isModalVisible = true;
    });

    debugPrint('Room tapped: $roomId');
    debugPrint('Room info: $roomInfo');

    // Show room information dialog
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('강의실 정보'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('방 ID: $roomId'),
                SizedBox(height: 8),
                Text('상세 정보:'),
                Text(roomInfo.toString()),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('닫기'),
              ),
            ],
          );
        },
      );
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
      body: InteractiveViewer(
        transformationController: _transformationController,
        boundaryMargin: EdgeInsets.all(50),
        minScale: 0.1,
        maxScale: 10.0,
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
                    if (shape['type'] == 'rect') {
                      return Positioned(
                        left: shape['x']?.toDouble() ?? 0,
                        top: shape['y']?.toDouble() ?? 0,
                        width: shape['width']?.toDouble() ?? 0,
                        height: shape['height']?.toDouble() ?? 0,
                        child: GestureDetector(
                          onTap: () => _onRoomTap(id, shape),
                          child: Container(
                            color: selectedRoomId == id
                                ? Colors.blue.withOpacity(0.3)
                                : Colors.transparent,
                            child: Container(
                              decoration: BoxDecoration(
                                border: selectedRoomId == id
                                    ? Border.all(color: Colors.blue, width: 2)
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      );
                    } else if (shape['type'] == 'polygon' &&
                        shape['points'] != null) {
                      final points = shape['points'] as List?;
                      if (points != null) {
                        return PolygonTapArea(
                          points: List<List<double>>.from(
                            points.map((p) => List<double>.from(p ?? [])),
                          ),
                          onTap: () => _onRoomTap(id, shape),
                        );
                      }
                    } else if (shape['type'] == 'path' && shape['points'] != null) {
                      final points = shape['points'] as List?;
                      if (points != null) {
                        return PolygonTapArea(
                          points: List<List<double>>.from(
                            points.map((p) => List<double>.from(p ?? [])),
                          ),
                          onTap: () => _onRoomTap(id, shape),
                        );
                      }
                    }
                    return const SizedBox.shrink();
                  });
                }),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "zoom_in",
            mini: true,
            onPressed: () {
              final matrix = Matrix4.copy(_transformationController.value);
              matrix.scale(1.2);
              _transformationController.value = matrix;
            },
            child: Icon(Icons.zoom_in),
          ),
          SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "zoom_out",
            mini: true,
            onPressed: () {
              final matrix = Matrix4.copy(_transformationController.value);
              matrix.scale(0.8);
              _transformationController.value = matrix;
            },
            child: Icon(Icons.zoom_out),
          ),
          SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "reset",
            mini: true,
            onPressed: () {
              _transformationController.value = Matrix4.identity();
            },
            child: Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}