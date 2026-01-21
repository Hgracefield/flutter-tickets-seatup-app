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

  // 필터 검색
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
      final data = json.decode(utf8.decode(res.bodyBytes));
      return (data['results'] as List).map((e) => Post.fromJson(e)).toList();
    });
  }

  // 티켓 거래 상태 (0: 판매중, 1: 거래완료)
  Future<String> updatePostStatus(int postSeq, int status) async {
    final url = Uri.parse("${GlobalData.url}/post/updateStatus?seq=$postSeq&status=$status");
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = json.decode(utf8.decode(res.bodyBytes));
      return data['results'];
    }
    return "Error";
  }

  Future<Post> selectPost(int seq) async {
    final res = await http.get(Uri.parse("${GlobalData.url}/post/selectPost/$seq"));
    final data = json.decode(utf8.decode(res.bodyBytes));
    return Post.fromJson(data['results'][0]);
  }

  Future insertPost(Post post) async {
    final url = Uri.parse("${GlobalData.url}/post/insert");
    final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: json.encode(post.toJson()));
    await refreshPost();
    final data = json.decode(utf8.decode(response.bodyBytes));
    return data['results'];
  }

  Future<void> refreshPost() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => fetchPost());
  }
}

final postNotifierProvider = AsyncNotifierProvider<PostNotifier, List<Post>>(PostNotifier.new);

final postDetailProvider = FutureProvider.family<Post, int>((ref, postSeq) async {
  return await ref.read(postNotifierProvider.notifier).selectPost(postSeq);
});