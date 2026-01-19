import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/grade.dart';
import 'package:seatup_app/util/global_data.dart';

class GradeNotifier extends AsyncNotifier<List<Grade>> {
  @override
  Future<List<Grade>> build() async {
    return await fetchGrade();
  }

  Future<List<Grade>> fetchGrade() async {
    final res = await http.get(Uri.parse("${GlobalData.url}/grade/select"));
    if (res.statusCode != 200) {
      throw Exception('불러오기 실패 ${res.statusCode}');
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    return (data['results'] as List).map((e) => Grade.fromJson(e)).toList();
  }

  Future insertGrade(Grade grade) async {
    final url = Uri.parse("${GlobalData.url}/grade/insert");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(grade.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception(
        '요청 실패 ${response.statusCode}: ${utf8.decode(response.bodyBytes)}',
      );
    }
    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshGrade();
    return data['result'];
  }

  Future<String> updateUser(Grade grade) async {
    final url = Uri.parse("${GlobalData.url}/grade/update");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(grade.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception(
        '요청 실패 ${response.statusCode}: ${utf8.decode(response.bodyBytes)}',
      );
    }
    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshGrade();
    return data['result'];
  }

  Future<void> refreshGrade() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => fetchGrade());
  }
} // GradeNotifier

final gradeNotifierProvider = AsyncNotifierProvider<GradeNotifier, List<Grade>>(
  GradeNotifier.new
);


