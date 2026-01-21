import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

import '../constants/api_keys.dart'; //  너희가 만든 키 파일 (kakaoRestApiKey 있어야 함)

// 이 함수가 하는일
// 1. 카카오 길찾기 API URL을 만들고
// 2. REST API 키로 요청 보내고
// 3. 응답에서 경로점(vertexes)을 뽑아서
// 4. List<LatLng>로 변환해서 반환
class KakaoRouteResult {
  final List<LatLng> points;
  final int distanceMeter;
  final int durationSec;

  const KakaoRouteResult({
    required this.points,
    required this.distanceMeter,
    required this.durationSec,
  });
}

class KakaoDirectionsRepository {
  ///  출발/도착 좌표로 "경로 점들"을 받아오는 함수
  Future<List<LatLng>> fetchRoutePoints({
    required double originLat, // 출발 위도
    required double originLng, // 출발 경도
    required double destLat, // 도착 위도
    required double destLng, // 도착 경도
  }) async {
    final result = await fetchRouteResult(
      originLat: originLat,
      originLng: originLng,
      destLat: destLat,
      destLng: destLng,
    );
    return result.points;
  }

  ///  경로 점 + 거리 + 시간 같이 받는 함수 (UI 더 예쁘게 만들 때 필요)
  Future<KakaoRouteResult> fetchRouteResult({
    required double originLat, // 출발 위도
    required double originLng, // 출발 경도
    required double destLat, // 도착 위도
    required double destLng, // 도착 경도
  }) async {
    //  카카오 directions API 주소 만들기
    //  중요: origin/destination은 "경도,위도" 순서로 넣어야 한다!
    final uri = Uri.https('apis-navi.kakaomobility.com', '/v1/directions', {
      'origin': '$originLng,$originLat', //  lng,lat
      'destination': '$destLng,$destLat', //  lng,lat
      'summary': 'false', //  경로 상세 점(vertexes) 받으려면 false 추천
    });

    http.Response res;

    //  디버그 로그 (진짜 실패 원인을 보려면 이거 꼭 필요)
    //  START는 "요청 보내기 전에" 찍어야 함수 호출 자체가 됐는지 확인 가능
    // ignore: avoid_print
    print('Kakao Directions START');

    //  요청 보내기
    try {
      res = await http
          .get(
            uri,
            headers: {
              'Authorization': 'KakaoAK $kakaoRestApiKey', //  REST API 키 사용
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw Exception('카카오 길찾기 API 요청 시간 초과');
    } catch (e) {
      throw Exception('카카오 길찾기 API 요청 중 예외 발생: $e');
    }

    //  디버그 로그 (진짜 실패 원인을 보려면 이거 꼭 필요)
    //  statusCode 200 아니면 body 안에 에러 메시지가 들어있는 경우가 많다.
    // ignore: avoid_print
    print('Kakao Directions statusCode: ${res.statusCode}');
    // ignore: avoid_print
    print('Kakao Directions body length: ${res.body.length}');

    //  substring은 길이가 300보다 짧으면 RangeError 터질 수 있어서 안전하게 잘라야 한다
    final previewLen = res.body.length < 300 ? res.body.length : 300;

    // ignore: avoid_print
    print('Kakao Directions body preview: ${res.body.substring(0, previewLen)}');

    //  실패 처리
    if (res.statusCode != 200) {
      throw Exception('카카오 길찾기 API 호출 실패: ${res.statusCode}\n${res.body}');
    }

    //  응답 JSON 파싱
    final data = jsonDecode(res.body) as Map<String, dynamic>;

    //  result_code 확인 (routes는 있어도 result_code가 실패일 수 있음)
    final routes = (data['routes'] as List<dynamic>?) ?? [];
    if (routes.isEmpty) {
      return const KakaoRouteResult(points: [], distanceMeter: 0, durationSec: 0);
    }

    final firstRoute = routes[0] as Map<String, dynamic>;
    final resultCode = firstRoute['result_code'];
    final resultMsg = firstRoute['result_msg'];

    if (resultCode != 0) {
      throw Exception('길찾기 실패: result_code=$resultCode, msg=$resultMsg');
    }

    // 거리/시간(있으면 summary에서 가져오고, 없으면 sections에서 합산)
    int distanceMeter = 0;
    int durationSec = 0;

    final summary = firstRoute['summary'];
    if (summary is Map<String, dynamic>) {
      distanceMeter = (summary['distance'] as num?)?.toInt() ?? 0;
      durationSec = (summary['duration'] as num?)?.toInt() ?? 0;
    } else {
      final sections = (firstRoute['sections'] as List<dynamic>?) ?? [];
      for (final section in sections) {
        final sectionMap = section as Map<String, dynamic>;
        distanceMeter += (sectionMap['distance'] as num?)?.toInt() ?? 0;
        durationSec += (sectionMap['duration'] as num?)?.toInt() ?? 0;
      }
    }

    //  vertexes를 LatLng 리스트로 변환해서 반환
    final points = _parseVertexesToLatLngList(data);

    //  points가 너무 많으면 addPolyline 때 화면이 멈출 수 있어서 downSample 처리
    //  step은 5~10 정도 추천
    final safePoints = downSample(points, step: 5);

    return KakaoRouteResult(
      points: safePoints,
      distanceMeter: distanceMeter,
      durationSec: durationSec,
    );
  }

  ///  points가 너무 많을 때 폴리라인 성능을 위해 downSample 하는 함수
  /// step=5면 5개 중 1개씩만 찍는다 (5~10 추천)
  List<LatLng> downSample(List<LatLng> points, {int step = 5}) {
    if (points.length <= 2) return points;
    if (step <= 1) return points;

    final sampled = <LatLng>[];

    for (int i = 0; i < points.length; i += step) {
      sampled.add(points[i]);
    }

    // 마지막 점은 무조건 포함
    if (sampled.isNotEmpty && sampled.last != points.last) {
      sampled.add(points.last);
    }

    return sampled;
  }

  ///  응답 JSON 안의 vertexes를 꺼내서
  /// List<LatLng>로 바꾸는 함수 (지도에 Polyline 그릴 수 있게)
  List<LatLng> _parseVertexesToLatLngList(Map<String, dynamic> data) {
    final routes = (data['routes'] as List<dynamic>?) ?? [];
    if (routes.isEmpty) return [];

    final firstRoute = routes[0] as Map<String, dynamic>;
    final sections = (firstRoute['sections'] as List<dynamic>?) ?? [];
    if (sections.isEmpty) return [];

    final points = <LatLng>[];

    //  sections는 여러 개일 수 있어서 전체를 다 돈다
    for (final section in sections) {
      final sectionMap = section as Map<String, dynamic>;
      final roads = (sectionMap['roads'] as List<dynamic>?) ?? [];

      for (final road in roads) {
        final roadMap = road as Map<String, dynamic>;

        // vertexes = [x1, y1, x2, y2, ...]
        // x=경도(lng), y=위도(lat)
        final rawVertexes = roadMap['vertexes'];

        if (rawVertexes is! List) continue;

        final vertexes = rawVertexes.cast<num>();

        for (int i = 0; i < vertexes.length - 1; i += 2) {
          final lng = vertexes[i].toDouble(); // x
          final lat = vertexes[i + 1].toDouble(); // y

          //  지도 LatLng는 (위도, 경도) 순서
          points.add(LatLng(lat, lng));
        }
      }
    }

    return points;
  }
}
