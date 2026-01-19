import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/post.dart';
import 'package:seatup_app/util/global_data.dart';
import 'dart:convert';
class PostNotifier extends AsyncNotifier<List<Post>>{
  @override
  FutureOr<List<Post>> build() async{
    return fetchPost();
  }

  Future<List<Post>> fetchPost() async
  {
    final res = await http.get(Uri.parse("${GlobalData.url}/post/allSelect"));
    if (res.statusCode != 200) {
      throw Exception('불러오기 실패 ${res.statusCode}');
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    return (data['results'] as List).map((e) => Post.fromJson(e),).toList();
  }

  Future<List<Post>> searchPost(String keyword) async
  {
    final res = await http.get(Uri.parse("${GlobalData.url}/post/search?keyword=$keyword"));
    if (res.statusCode != 200) {
      throw Exception('불러오기 실패 ${res.statusCode}');
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    // print(data);
    return (data['results'] as List).map((e) => Post.fromJson(e),).toList();
  }

  Future insertPost(Post post) async{
    final url = Uri.parse("${GlobalData.url}/post/insert");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(post.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('불러오기 실패 ${response.statusCode} / ${response.body}');
    }

    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshPost();
    return data['results'];
  }

  Future<void> refreshPost() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async => fetchPost(),
    );
  }
} // PostNotifier

final postNotifierProvider = AsyncNotifierProvider<PostNotifier, List<Post>>(
  PostNotifier.new
);