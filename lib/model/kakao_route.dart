import 'package:kakao_map_plugin/kakao_map_plugin.dart';

class KakaoRoute {
  final List<LatLng> points; // 지도에 선 그릴 좌표들
  final int distance; // meter
  final int duration; // second

  KakaoRoute({
    required this.points,
    required this.distance,
    required this.duration,
  });
}
