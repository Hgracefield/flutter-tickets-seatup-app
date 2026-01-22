import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/curtain.dart';
import 'package:seatup_app/util/global_data.dart';

class CurtainNotifier extends AsyncNotifier<List<Curtain>> {
  @override
  FutureOr<List<Curtain>> build() async {
    return fetchCurtain();
  }

  Future<List<Curtain>> fetchCurtain() async {
    final res = await http.get(Uri.parse("${GlobalData.url}/curtain/select"));
    if (res.statusCode != 200) {
      throw Exception('불러오기 실패 ${res.statusCode}');
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    return (data['results'] as List).map((e) => Curtain.fromJson(e)).toList();
  }

  Future<Curtain> selectCurtain(int curtainSeq) async {
    final res = await http.get(
      Uri.parse("${GlobalData.url}/curtain/select/$curtainSeq"),
    );
    if (res.statusCode != 200) {
      throw Exception('불러오기 실패 ${res.statusCode}');
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    return (data['results'] as List)
        .map((e) => Curtain.fromJson(e))
        .toList()
        .first;
  }

  Future<List<Curtain>> searchCurtain(String keyword) async {
    final res = await http.get(
      Uri.parse("${GlobalData.url}/curtain/search?keyword=$keyword"),
    );
    if (res.statusCode != 200) {
      throw Exception('불러오기 실패 ${res.statusCode}');
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    // print(data);
    return (data['results'] as List).map((e) => Curtain.fromJson(e)).toList();
  }

  // 시간가져오기위한 함수
  Future<List<Map<String,dynamic>>> fetchCurtainAll() async {
    final res = await http.get(Uri.parse("${GlobalData.url}/curtain/selectTime"));
    if (res.statusCode != 200) {
      throw Exception('불러오기 실패 ${res.statusCode}');
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
     final results = (data['results'] as List)
      .map((e) => Map<String, dynamic>.from(e as Map))
      .toList();

    return results;
  }  

  Future<String> insertCurtain(Map<String, dynamic> curtain) async {
   final url = Uri.parse("${GlobalData.url}/curtain/insert");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      // headers: {'Content-Type': 'x-www-form-urlencoded'},
      body: json.encode(curtain),
    );
    if (response.statusCode != 200) {
      throw Exception(
        '요청 실패 ${response.statusCode}: ${utf8.decode(response.bodyBytes)}',
      );
    }
    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshCurtain();
    return data['result'];
  }  

  Future<void> refreshCurtain() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => fetchCurtain());
  }
  

} // CurtainNotifier

final curtainNotifierProvider =
    AsyncNotifierProvider<CurtainNotifier, List<Curtain>>(CurtainNotifier.new);

// 시간가져오기위한 함수
final curtainAllProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final notifier = ref.read(curtainNotifierProvider.notifier);
  return await notifier.fetchCurtainAll();
});

