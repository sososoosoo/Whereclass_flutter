class ApiConfig {
  static const String baseUrl = 'http://localhost:8080/api';

  // API 엔드포인트
  static const String buildingsEndpoint = '/buildings';

  // 전체 URL 생성
  static String get buildingsUrl => '$baseUrl$buildingsEndpoint';
  static String buildingUrl(String buildingId) => '$baseUrl$buildingsEndpoint/$buildingId';
  static String floorsUrl(String buildingId) => '$baseUrl$buildingsEndpoint/$buildingId/floors';
  static String floorUrl(String buildingId, String floorId) => '$baseUrl$buildingsEndpoint/$buildingId/floors/$floorId';
  static String roomUrl(String buildingId, String floorId, String roomId) => '$baseUrl$buildingsEndpoint/$buildingId/floors/$floorId/rooms/$roomId';
}