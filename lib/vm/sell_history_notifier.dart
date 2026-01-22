import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/util/global_data.dart';

class SellHistoryNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  
  @override
  FutureOr<List<Map<String, dynamic>>> build() async {
    return []; 
  }

  Future<void> fetchHistory(int userId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final response = await http.get(
        Uri.parse("${GlobalData.url}/post/salesHistory/$userId"),
      );

      if (response.statusCode != 200) {
        throw Exception('서버 응답 오류: ${response.statusCode}');
      }

      final data = json.decode(utf8.decode(response.bodyBytes));
      return List<Map<String, dynamic>>.from(data['results']);
    });
  }
}


final sellHistoryProvider =
    AsyncNotifierProvider<SellHistoryNotifier, List<Map<String, dynamic>>>(
  SellHistoryNotifier.new,
);