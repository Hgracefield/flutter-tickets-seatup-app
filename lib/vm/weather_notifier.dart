import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/constants/api_keys.dart';
import 'package:seatup_app/model/weather.dart';
import 'package:http/http.dart' as http;

final weatherProvider = FutureProvider<WeatherModel>((ref) async {
  const url = 'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0';

  final now = DateTime.now();
  final baseDate =
      '${now.year}'
      '${now.month.toString().padLeft(2, '0')}'
      '${now.day.toString().padLeft(2, '0')}';

  final uri = Uri.parse(
    '$url/getVilageFcst' // URL -> 단기예보조회
    '?serviceKey=$weatherServiceKey' // 인증키
    '&pageNo=1' // 페이지 번호
    '&numOfRows=10' // 한 페이지 결과 수
    '&dataType=JSON' // 요청자료형식(XML/JSON)
    '&base_date=$baseDate' // 오늘 발표된 예보 (00~02시 제외)
    '&base_time=${baseTime(now)}' // 최신 발표 시각
    '&nx=61' // 예보지점의 X 좌표값 -> 강남구
    '&ny=126', // 예보지점의 Y 좌표값 -> 강남구
  );

  final response = await http.get(uri).timeout(const Duration(seconds: 8));

  if (response.statusCode != 200) {
    throw Exception('날씨 데이터 로딩 실패');
  }

  final data = jsonDecode(utf8.decode(response.bodyBytes));
  return WeatherModel.fromJson(data);
});

// 현재 시각 기준 최신값
String baseTime(DateTime now) {
  final hour = now.hour;
  final minute = now.minute;

  // 최신 API는 발표 시각 기준 10분 이후에 반영되므로 아래와 같이 계산
  if (hour < 2 || (hour == 2 && minute < 10)) return '2300';
  if (hour < 5 || (hour == 5 && minute < 10)) return '0200';
  if (hour < 8 || (hour == 8 && minute < 10)) return '0500';
  if (hour < 11 || (hour == 11 && minute < 10)) return '0800';
  if (hour < 14 || (hour == 14 && minute < 10)) return '1100';
  if (hour < 17 || (hour == 17 && minute < 10)) return '1400';
  if (hour < 20 || (hour == 20 && minute < 10)) return '1700';
  if (hour < 23 || (hour == 23 && minute < 10)) return '2000';
  return '2300';
}
