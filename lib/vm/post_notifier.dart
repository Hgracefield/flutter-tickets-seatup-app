import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/post.dart';
import 'package:seatup_app/util/global_data.dart';
import 'dart:convert';

class PostNotifier extends AsyncNotifier<List<Post>> {
  @override
  FutureOr<List<Post>> build() async {
    return fetchPost();
  }

  Future<List<Post>> fetchPost() async {
    final res = await http.get(Uri.parse("${GlobalData.url}/post/allSelect"));
    if (res.statusCode != 200) throw Exception('불러오기 실패');
    final data = json.decode(utf8.decode(res.bodyBytes));
    return (data['results'] as List).map((e) => Post.fromJson(e)).toList();
  }

  // [중요] 필터 검색 메서드
  Future<void> fetchFilteredPosts({
    required int curtainId,
    required String date,
    required String time,
    required int gradeBit,
    required String area,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final url = "${GlobalData.url}/post/filter?curtain=$curtainId&date=$date&time=$time&grade=$gradeBit&area=$area";
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) throw Exception('검색 실패');
      final data = json.decode(utf8.decode(res.bodyBytes));
      return (data['results'] as List).map((e) => Post.fromJson(e)).toList();
    });
  }

  Future insertPost(Post post) async {
    final url = Uri.parse("${GlobalData.url}/post/insert");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(post.toJson()),
    );
    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshPost();
    return data['results'];
  }

  Future<void> refreshPost() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => fetchPost());
  }
}

final postNotifierProvider = AsyncNotifierProvider<PostNotifier, List<Post>>(PostNotifier.new);