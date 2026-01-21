import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/util/global_data.dart';
import 'package:http/http.dart' as http;

class PurchaseNotifier extends AsyncNotifier<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> build() async {
    return {};
  }

  Future<void> load(int seq) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return await selectPurchaseList(seq);
    });
  }

  Future<Map<String, dynamic>> selectPurchaseList(int seq) async {
    final res = await http.get(
      Uri.parse("${GlobalData.url}/post/selectPostDetail/$seq"),
    );

    if (res.statusCode != 200) {
      throw Exception('상세 정보 로드 실패 (${res.statusCode})');
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    final List list = data['results'] as List;
    if (list.isEmpty) throw Exception('데이터가 없습니다.');
    return list.first as Map<String, dynamic>;
  }
}
final purchaseNotifierProvider = AsyncNotifierProvider<PurchaseNotifier,Map<String,dynamic>>(PurchaseNotifier.new);

final purchaseDetailProvider =
    FutureProvider.family <Map<String, dynamic>, int>(
(ref, id) async{
  return await ref.read(purchaseNotifierProvider.notifier).selectPurchaseList(id);
},
);
