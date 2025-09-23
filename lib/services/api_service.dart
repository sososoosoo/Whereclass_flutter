import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'api_config.dart';

class ApiService {
  /// 건물명을 백엔드 ID로 변환 (기존 Firebase 매핑과 동일)
  static String getBuildingId(String buildingName) {
    final mappings = {
      '컨버젼스 홀': 'convergence_hall',
      '백운관': 'baekun_hall',
      '창조관': 'changjo_hall',
      '청송관': 'cheongsong_hall',
      '미래관': 'mirae_hall',
      '정의관': 'jeongui_hall',
    };
    return mappings[buildingName] ??
        buildingName.toLowerCase().replaceAll(' ', '_');
  }

  /// 건물ID와 층 번호로 문서 ID 생성 (기존과 동일)
  static String generateDocumentId(String buildingId, String floorNum) {
    return '${buildingId}_floor_$floorNum';
  }

  /// 백엔드에서 SVG 데이터 가져오기 (Firebase getSvgData 대체)
  static Future<String?> getSvgData(String buildingId, String documentId) async {
    try {
      final url = ApiConfig.floorUrl(buildingId, documentId);
      debugPrint('API 요청: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // SVG 데이터는 현재 API 구조에서는 별도 처리 필요
        // 임시로 floor 정보 반환 (나중에 SVG 파일 서빙 추가)
        debugPrint('API 응답 성공: ${data.toString()}');
        return data.toString(); // 임시 응답
      } else if (response.statusCode == 404) {
        debugPrint('층 데이터 없음: $buildingId/$documentId');
        return null;
      } else {
        debugPrint('API 오류: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('API 호출 오류: $e');
      return null;
    }
  }

  /// 사용 가능한 건물 목록 가져오기 (Firebase getAvailableBuildings 대체)
  static Future<List<String>> getAvailableBuildings() async {
    try {
      final url = ApiConfig.buildingsUrl;
      debugPrint('API 요청: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> buildings = json.decode(response.body);
        final buildingIds = buildings.map((building) => building['id'] as String).toList();

        debugPrint('사용 가능한 건물: $buildingIds');
        return buildingIds;
      } else {
        debugPrint('건물 목록 API 오류: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('건물 목록 API 호출 오류: $e');
      return [];
    }
  }

  /// 특정 건물의 사용 가능한 층 목록 가져오기 (Firebase getAvailableFloors 대체)
  static Future<List<String>> getAvailableFloors(String buildingId) async {
    try {
      final url = ApiConfig.floorsUrl(buildingId);
      debugPrint('API 요청: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> floors = json.decode(response.body);
        final floorIds = floors.map((floor) => floor as String).toList();

        debugPrint('$buildingId 사용 가능한 층: $floorIds');
        return floorIds;
      } else {
        debugPrint('층 목록 API 오류: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('층 목록 API 호출 오류: $e');
      return [];
    }
  }

  /// 특정 건물 정보 가져오기
  static Future<Map<String, dynamic>?> getBuildingData(String buildingId) async {
    try {
      final url = ApiConfig.buildingUrl(buildingId);
      debugPrint('API 요청: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('건물 정보 조회 성공: $buildingId');
        return data;
      } else {
        debugPrint('건물 정보 API 오류: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('건물 정보 API 호출 오류: $e');
      return null;
    }
  }
}