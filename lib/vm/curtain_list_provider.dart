import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../model/curtain_list.dart';
import '../util/global_data.dart';
import 'category_provider.dart';

final curtainListProvider =
    AsyncNotifierProvider<CurtainListNotifier, List<CurtainList>>(
      CurtainListNotifier.new,
    );

class CurtainListNotifier extends AsyncNotifier<List<CurtainList>> {
  String _keyword = "";

  @override
  Future<List<CurtainList>> build() async {
    final typeSeq = ref.watch(
      categoryFilterProvider.select((s) => s.typeSeq),
    );

    if (_keyword.isEmpty) {
      return _fetchSimpleList(typeSeq: typeSeq);
    } else {
      return _searchSimpleList(keyword: _keyword, typeSeq: typeSeq);
    }
  }

  Future<void> search(String keyword) async {
    _keyword = keyword.trim();
    await _reload();
  }

  Future<void> clearSearch() async {
    _keyword = "";
    await _reload();
  }

  Future<void> refresh() async {
    await _reload();
  }

  Future<void> _reload() async {
    state = const AsyncLoading();

    final typeSeq = ref.read(categoryFilterProvider).typeSeq;

    state = await AsyncValue.guard(() async {
      if (_keyword.isEmpty) {
        return _fetchSimpleList(typeSeq: typeSeq);
      } else {
        return _searchSimpleList(keyword: _keyword, typeSeq: typeSeq);
      }
    });
  }

  Future<List<CurtainList>> _fetchSimpleList({int? typeSeq}) async {
    final base = Uri.parse("${GlobalData.url}/curtain/simple-list");

    final uri = (typeSeq == null)
        ? base
        : base.replace(
            queryParameters: {"type_seq": typeSeq.toString()},
          );

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception("서버 오류: ${res.statusCode}");
    }

    final decoded = json.decode(utf8.decode(res.bodyBytes));
    final results = decoded["results"];

    if (results is! List) {
      final msg = decoded["message"] ?? "서버 응답 Error";
      throw Exception(msg);
    }

    return results.map((e) => CurtainList.fromJson(e)).toList();
  }

  Future<List<CurtainList>> _searchSimpleList({
    required String keyword,
    int? typeSeq,
  }) async {
    final base = Uri.parse("${GlobalData.url}/curtain/simple-search");

    final params = <String, String>{
      "keyword": keyword,
      if (typeSeq != null) "type_seq": typeSeq.toString(),
    };

    final uri = base.replace(queryParameters: params);

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception("서버 오류: ${res.statusCode}");
    }

    final decoded = json.decode(utf8.decode(res.bodyBytes));
    final results = decoded["results"];

    if (results is! List) {
      final msg = decoded["message"] ?? "서버 응답 Error";
      throw Exception(msg);
    }

    return results.map((e) => CurtainList.fromJson(e)).toList();
  }
}
