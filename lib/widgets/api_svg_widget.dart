import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:whc_proto/services/api_service.dart';
import 'package:whc_proto/widgets/polygon_tap_area.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class ApiSvgWidget extends StatefulWidget {
  const ApiSvgWidget({
    super.key,
    required this.buildingName,
    required this.floorNum,
    this.width,
    this.height,
    this.onSvgElementTap,
  });

  final String buildingName;
  final String floorNum;
  final double? width;
  final double? height;
  final void Function(String svgId, Map<String, dynamic> itemInfo)?
      onSvgElementTap;

  @override
  State<ApiSvgWidget> createState() => _ApiSvgWidgetState();
}

class _ApiSvgWidgetState extends State<ApiSvgWidget> {
  List<dynamic>? _roomShapes;
  String? _svgData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSvgData();
  }

  @override
  void didUpdateWidget(ApiSvgWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.buildingName != widget.buildingName ||
        oldWidget.floorNum != widget.floorNum) {
      _loadSvgData();
    }
  }

  Future<void> _loadSvgData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // API에서 건물 데이터 로드 시도
      final buildingId = ApiService.getBuildingId(widget.buildingName);
      final documentId = ApiService.generateDocumentId(buildingId, widget.floorNum);

      debugPrint('API SVG Widget - Building: $buildingId, Floor: $documentId');

      // API에서 층 데이터 시도 (현재는 SVG 데이터 대신 층 정보 반환)
      final apiResponse = await ApiService.getSvgData(buildingId, documentId);

      // 로컬 JSON에서 SVG 및 클릭 가능 영역 데이터 로드 (임시 방안)
      String? svgData;
      List<dynamic>? roomShapes;

      try {
        final assetPath = 'assets/output_json/flutter_svg_data.json';
        final jsonStr = await rootBundle.loadString(assetPath);
        final fullData = json.decode(jsonStr) as Map<String, dynamic>;

        // Navigate to the specific floor data
        final floorName = '${buildingId}_floor_${widget.floorNum}';
        final buildingsData = fullData['buildings'] as Map<String, dynamic>;
        final buildingData = buildingsData[buildingId] as Map<String, dynamic>?;

        if (buildingData != null) {
          final floorsData = buildingData['floors'] as Map<String, dynamic>;
          final floorData = floorsData[floorName] as Map<String, dynamic>?;

          if (floorData != null) {
            // SVG 파일 확인 (실제로는 SVG 데이터가 JSON에 있다면 가져오기)
            // 현재는 로컬 JSON의 클릭 가능 영역만 사용
            final clickableAreas = floorData['clickable_areas'] as Map<String, dynamic>? ?? {};
            roomShapes = clickableAreas.values.toList();

            // SVG 데이터 임시 처리 (실제 SVG 파일이나 데이터가 있다면 사용)
            svgData = '''
              <svg width="1000" height="1000" viewBox="0 0 1000 1000" xmlns="http://www.w3.org/2000/svg">
                <rect width="1000" height="1000" fill="#f0f0f0" stroke="#ccc" stroke-width="2"/>
                <text x="500" y="500" text-anchor="middle" fill="#666" font-size="24">
                  ${widget.buildingName} ${widget.floorNum}층
                </text>
                <text x="500" y="530" text-anchor="middle" fill="#666" font-size="14">
                  API 연결 성공: ${apiResponse != null ? '✓' : '✗'}
                </text>
              </svg>
            ''';

            debugPrint('로컬 JSON에서 ${roomShapes?.length ?? 0}개 클릭 영역 로드됨');
          }
        }
      } catch (e) {
        debugPrint('로컬 JSON 로드 오류: $e');
        svgData = '''
          <svg width="1000" height="1000" viewBox="0 0 1000 1000" xmlns="http://www.w3.org/2000/svg">
            <rect width="1000" height="1000" fill="#ffeeee" stroke="#ff0000" stroke-width="2"/>
            <text x="500" y="500" text-anchor="middle" fill="#ff0000" font-size="16">
              데이터 로드 오류
            </text>
          </svg>
        ''';
      }

      if (mounted) {
        setState(() {
          _svgData = svgData;
          _roomShapes = roomShapes;
          _isLoading = false;
          if (svgData == null) {
            _errorMessage = 'SVG 데이터를 찾을 수 없습니다.';
          }
        });
      }
    } catch (e) {
      debugPrint('API SVG 로드 오류: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'API 연결 실패: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('API에서 데이터 로드 중...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSvgData,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_svgData == null) {
      return const Center(
        child: Text('SVG 데이터가 없습니다.'),
      );
    }

    return Stack(
      children: [
        Container(
          width: widget.width,
          height: widget.height,
          child: SvgPicture.string(
            _svgData!,
            fit: BoxFit.contain,
            placeholderBuilder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
        // 클릭 가능한 영역 추가 (기존 로직과 동일)
        if (_roomShapes != null)
          ..._roomShapes!.map((room) {
            final polygon = room['polygon'] as List<dynamic>?;
            final roomId = room['id'] as String? ?? '';
            final displayName = room['display_name'] as String? ?? '';

            if (polygon != null && polygon.isNotEmpty) {
              // Polygon 좌표를 List<List<double>>로 변환
              final points = polygon.map<List<double>>((point) {
                final x = (point['x'] as num?)?.toDouble() ?? 0.0;
                final y = (point['y'] as num?)?.toDouble() ?? 0.0;
                return [x, y];
              }).toList();

              return PolygonTapArea(
                points: points,
                onTap: () {
                  debugPrint('클릭된 강의실: $roomId ($displayName)');
                  if (widget.onSvgElementTap != null) {
                    widget.onSvgElementTap!(roomId, {
                      'id': roomId,
                      'display_name': displayName,
                      'type': 'room',
                      ...room,
                    });
                  }
                },
              );
            }
            return const SizedBox.shrink();
          }).toList(),
      ],
    );
  }
}