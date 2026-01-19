import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/area.dart';
import 'package:seatup_app/util/global_data.dart';
import 'dart:convert';
class AreaNotifier extends AsyncNotifier<List<Area>>{
  @override
  Future<List<Area>> build() async {
   return await fetchArea();
  }
  Future<List<Area>> fetchArea() async {
    final res = await http.get(Uri.parse("${GlobalData.url}/grade/select"));
    if (res.statusCode != 200) {
      throw Exception('불러오기 실패 ${res.statusCode}');
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    return (data['results'] as List).map((e) => Area.fromJson(e)).toList();
  }

  Future insertArea(Area area) async {
    final url = Uri.parse("${GlobalData.url}/grade/insert");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(area.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception(
        '요청 실패 ${response.statusCode}: ${utf8.decode(response.bodyBytes)}',
      );
    }
    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshArea();
    return data['result'];
  }

  Future<String> updateUser(Area area) async {
    final url = Uri.parse("${GlobalData.url}/grade/update");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(area.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception(
        '요청 실패 ${response.statusCode}: ${utf8.decode(response.bodyBytes)}',
      );
    }
    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshArea();
    return data['result'];
  }

  Future<void> refreshArea() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => fetchArea());
  }
} // AreaNotifier

final areaNotifierProvider = AsyncNotifierProvider<AreaNotifier, List<Area>>(
  AreaNotifier.new
);


