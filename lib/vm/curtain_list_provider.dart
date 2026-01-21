import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../model/curtain_list.dart';
import '../util/global_data.dart';
import 'category_provider.dart'; // [추가] 카테고리 프로바이더 임포트

final curtainListProvider =
    AsyncNotifierProvider<CurtainListNotifier, List<CurtainList>>(
      CurtainListNotifier.new,
    );

class CurtainListNotifier extends AsyncNotifier<List<CurtainList>> {
  String _keyword = "";

  @override
  Future<List<CurtainList>> build() async {
    // 1. [핵심] 카테고리 상태를 감시합니다. 
    // 카테고리가 바뀌면 build가 자동으로 다시 실행됩니다.
    final category = ref.watch(selectedCategoryProvider);

    // 2. 카테고리에 따른 DB 타입 번호 매핑
    int? typeSeq;
    if (category == TicketCategory.musical) {
      typeSeq = 2; // 뮤지컬은 2번
    }
    // 추가 카테고리가 있다면 여기에 else if로 추가

    // 3. 데이터를 가져올 때 타입 번호를 넘겨줍니다.
    return _fetchSimpleList(typeSeq: typeSeq);
  }

  // 검색
  Future<void> search(String keyword) async {
    _keyword = keyword.trim();
    await _reload();
  }

  // 검색 초기화
  Future<void> clearSearch() async {
    _keyword = "";
    await _reload();
  }

  // 새로고침
  Future<void> refresh() async {
    await _reload();
  }

  // [수정] typeSeq 파라미터를 추가하여 필터링이 가능하게 함
  Future<List<CurtainList>> _fetchSimpleList({int? typeSeq}) async {
    // URL에 type_seq 쿼리 파라미터 추가
    String urlString = "${GlobalData.url}/curtain/simple-list";
    if (typeSeq != null) {
      urlString += "?type_seq=$typeSeq";
    }
    
    final url = Uri.parse(urlString);
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
    int? typeSeq,
  }) async {
    // 검색 시에도 카테고리 필터가 유지되도록 URL 구성
    String urlString = "${GlobalData.url}/curtain/simple-search?keyword=${Uri.encodeQueryComponent(keyword)}";
    if (typeSeq != null) {
      urlString += "&type_seq=$typeSeq";
    }

    final url = Uri.parse(urlString);
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

    // 현재 선택된 카테고리 정보를 다시 가져옴
    final category = ref.read(selectedCategoryProvider);
    int? typeSeq = (category == TicketCategory.musical) ? 2 : null;

    state = await AsyncValue.guard(() async {
      if (_keyword.isEmpty) {
        return _fetchSimpleList(typeSeq: typeSeq);
      } else {
        return _searchSimpleList(keyword: _keyword, typeSeq: typeSeq);
      }
    });
  }
}