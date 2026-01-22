import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/util/global_data.dart';


class AdminCurtainNotifier extends AsyncNotifier<List<Map<String,dynamic>>>{
  @override
  FutureOr<List<Map<String,dynamic>>> build() async{
   return await fetchCurtainAll();
  }

   // 시간가져오기위한 함수
  Future<List<Map<String,dynamic>>> fetchCurtainAll() async {
    final res = await http.get(Uri.parse("${GlobalData.url}/curtain/selectTime"));
    if (res.statusCode != 200) {
      throw Exception('불러오기 실패 ${res.statusCode}');
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
     final results = (data['results'] as List)
      .map((e) => Map<String, dynamic>.from(e as Map))
      .toList();
    return results;
  }  

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(fetchCurtainAll);
  }
}

final adminCurtainNotifer = AsyncNotifierProvider<AdminCurtainNotifier, List<Map<String,dynamic>>>(
  AdminCurtainNotifier.new
);

// final curtainAllProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
//   final notifier = ref.read(CurtainDashboardNotifier.notifier);
//   return await notifier.fetchCurtainAll();
// });
