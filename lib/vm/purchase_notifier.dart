import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/purchase.dart';
import 'package:seatup_app/util/global_data.dart';
import 'package:http/http.dart' as http;

class PurchaseNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    return [];
  }

  Future<void> load(int userId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return await selectPurchaseList(userId);
    });
  }

  // insert
  Future<void> insertPurchase(Purchase p) async {
  final url = Uri.parse("${GlobalData.url}/purchase/insert");

  final body = jsonEncode(p.toInsertJson());
  print('INSERT BODY => $body');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(p.toInsertJson()), // insert 전용
  );

  if (response.statusCode != 200 && response.statusCode != 201) {
    throw Exception(
      '구매 등록 실패 (${response.statusCode}) : '
      '${utf8.decode(response.bodyBytes)}',
    );
  }
}

   Future<List<Map<String, dynamic>>> selectPurchaseList(int userId) async {
    
    final res = await http.get(
      Uri.parse("${GlobalData.url}/purchase/selectPurchaseDetail/$userId"),
    );

    print("STATUS => ${res.statusCode}");
    print("BODY => ${utf8.decode(res.bodyBytes)}");
    if (res.statusCode != 200) {
      throw Exception('상세 정보 로드 실패: ${utf8.decode(res.bodyBytes)}');
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    final results = data['results'];

    // ✅ results가 List가 아닐 때도 안전 처리
    if (results is List) {
      return results.cast<Map<String, dynamic>>();
    }
    if (results is Map) {
      return [results.cast<String, dynamic>()];
    }
    return [];
  }
}
final purchaseNotifierProvider =
    AsyncNotifierProvider<PurchaseNotifier, List<Map<String, dynamic>>>(
        PurchaseNotifier.new);

final purchaseDetailProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>((ref, id) async {
  return await ref
      .read(purchaseNotifierProvider.notifier)
      .selectPurchaseList(id);
});

