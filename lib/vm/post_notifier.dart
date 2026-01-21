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

  // 구매 필터 검색
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
      if (res.statusCode != 200) throw Exception('필터 검색 실패');
      final data = json.decode(utf8.decode(res.bodyBytes));
      return (data['results'] as List).map((e) => Post.fromJson(e)).toList();
    });
  }

  // 개별 포스트 상세 조회
  Future<Post> selectPost(int seq) async {
    final res = await http.get(Uri.parse("${GlobalData.url}/post/selectPost/$seq"));
    if (res.statusCode != 200) throw Exception('상세 정보 로드 실패');
    final data = json.decode(utf8.decode(res.bodyBytes));
    final List list = data['results'];
    if (list.isEmpty) throw Exception('데이터가 없습니다.');
    return Post.fromJson(list.first);
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

  // 티켓번호 만드는 함수
  String ticketNumber(String date , int postSeq , int curtainId){
    final List<String> value = date.split('-');
    String dateNumber = '';
    for (int i = 0; i < value.length; i++) {
      dateNumber = dateNumber + value[i];
    }
    final ticketnumber = postSeq.toString() + dateNumber + curtainId.toString();
    return ticketnumber;
  }

  // 개별 포스트 상세 조회(2)
  Future<Map<String, dynamic>> selectPostAll(int seq) async {
    final res = await http.get(Uri.parse("${GlobalData.url}/post/selectPost/$seq"));
    if (res.statusCode != 200) throw Exception('상세 정보 로드 실패');
    final data = json.decode(utf8.decode(res.bodyBytes));
    final List list = data['results'];
    if (list.isEmpty) throw Exception('데이터가 없습니다.');
    return list.first;
  }
}

final postNotifierProvider = AsyncNotifierProvider<PostNotifier, List<Post>>(PostNotifier.new);

// 상세 페이지용 Provider (Family)
final postDetailProvider = FutureProvider.family<Post, int>((ref, postSeq) async {
  return await ref.read(postNotifierProvider.notifier).selectPost(postSeq);
});

final postSelectAllProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, postSeq) async {
  return await ref.read(postNotifierProvider.notifier).selectPostAll(postSeq);
});