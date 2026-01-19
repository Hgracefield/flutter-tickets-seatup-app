import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/title.dart';
import 'package:seatup_app/util/global_data.dart';
import 'package:http/http.dart' as http;

class TitleState {
  final String title_contents;

  TitleState(
    {
      this.title_contents = '',
    }
  );

  TitleState copywith({String? title_contents}){
    return TitleState(
      title_contents: title_contents ?? this.title_contents,
    );
  }
} // TitleState

class TitleProvider extends AsyncNotifier<List<Title>> {
  final String baseUrl = GlobalData.url;

  @override
  FutureOr<List<Title>> build() async{
    return await fetchTitles();
  }

  // select
  Future<List<Title>> fetchTitles() async{
    final res = await http.get(Uri.parse("$baseUrl/title/select"));

    if (res.statusCode != 200) {
      throw Exception("불러오기 실패: ${res.statusCode}");
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    return (data['results'] as List).map((e) => Title.fromJson(e),).toList();
  }

   // insert
   Future<List<Title>> insertTitles(Title t) async {
    final url = Uri.parse("$baseUrl/title/insert");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(t.toJson()),
    );
    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshTitle();
    return data['result'];
  }

  // update
  Future<String> updateTitles(Title t) async {
    final url = Uri.parse('$baseUrl/title/update');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(t.toJson()),
    );
    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshTitle();
    return data['result'];
  }

  Future<String> deleteTitles(String code) async {
    final url = Uri.parse('$baseUrl/title/delete');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'code': code}),
    );
    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshTitle();
    return data['result'];
  }

  Future<void> refreshTitle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async => fetchTitles(),
    );
  }
} // StaffNotifier

final titleNotifierProvider =
    AsyncNotifierProvider<TitleProvider, List<Title>>(
      TitleProvider.new
    );