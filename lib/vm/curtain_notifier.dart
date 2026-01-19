import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/curtain.dart';
import 'package:seatup_app/util/global_data.dart';
class CurtainNotifier extends AsyncNotifier<List<Curtain>>{

  @override
  FutureOr<List<Curtain>> build() async {
    return fetchCurtain();
  }

  Future<List<Curtain>> fetchCurtain() async{
    final res = await http.get(Uri.parse("${GlobalData.url}/curtain/select"));
    if (res.statusCode != 200) {
      throw Exception('불러오기 실패 ${res.statusCode}');
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    return (data['results'] as List).map((e) => Curtain.fromJson(e),).toList();
  }

  Future<List<Curtain>> searchCurtain(String keyword) async
  {
    final res = await http.get(Uri.parse("${GlobalData.url}/curtain/search?keyword=$keyword"));
    if (res.statusCode != 200) {
      throw Exception('불러오기 실패 ${res.statusCode}');
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    // print(data);
    return (data['results'] as List).map((e) => Curtain.fromJson(e),).toList();
  }

} // CurtainNotifier

final curtainNotifierProvider = AsyncNotifierProvider<CurtainNotifier, List<Curtain>>(
  CurtainNotifier.new);