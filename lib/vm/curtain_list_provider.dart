import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../model/curtain_list.dart';
import '../util/global_data.dart';

final curtainListProvider =
    AsyncNotifierProvider<CurtainListNotifier, List<CurtainList>>(
      CurtainListNotifier.new,
    );

class CurtainListNotifier extends AsyncNotifier<List<CurtainList>> {
  String _keyword = "";

  @override
  Future<List<CurtainList>> build() async {
    //  앱 처음 들어오면 전체 리스트 자동 로드
    return _fetchSimpleList();
  }

  //  검색
  Future<void> search(String keyword) async {
    _keyword = keyword.trim();
    await _reload();
  }
  //  검색 초기화 = 전체 리스트

  Future<void> clearSearch() async {
    _keyword = "";
    await _reload();
  }

  //  새로고침

  Future<void> refresh() async {
    await _reload();
  }
  // ================================
  //  아래가 "API 호출 부분" (Repo 역할)
  // ================================

  Future<List<CurtainList>> _fetchSimpleList() async {
    final url = Uri.parse("${GlobalData.url}/curtain/simple-list");
    final res = await http.get(url);

    if (res.statusCode != 200) {
      throw Exception("서버 오류: ${res.statusCode}");
    }

    final decoded = json.decode(utf8.decode(res.bodyBytes));
    final list = decoded["results"] as List;
    return list.map((e) => CurtainList.fromJson(e)).toList();
  }

  Future<List<CurtainList>> _searchSimpleList({
    required String keyword,
  }) async {
    final url = Uri.parse(
      "${GlobalData.url}/curtain/simple-search?keyword=${Uri.encodeQueryComponent(keyword)}",
    );
    final res = await http.get(url);

    if (res.statusCode != 200) {
      throw Exception("서버 오류: ${res.statusCode}");
    }

    final decoded = json.decode(utf8.decode(res.bodyBytes));
    final list = decoded["results"] as List;
    return list.map((e) => CurtainList.fromJson(e)).toList();
  }

  Future<void> _reload() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      if (_keyword.isEmpty) {
        return _fetchSimpleList();
      } else {
        return _searchSimpleList(keyword: _keyword);
      }
    });
  }
}
