import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/bank.dart';
import 'package:seatup_app/util/global_data.dart';
import 'package:http/http.dart' as http;
class BankNotifier extends AsyncNotifier<List<Bank>>{
  @override
  Future<List<Bank>> build() async {
   return await fetchBank();
  }
  Future<List<Bank>> fetchBank() async {
     String url = "${GlobalData.url}/bank/select";
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) {
      throw Exception('불러오기 실패 ${res.statusCode}');
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    return (data['results'] as List).map((e) => Bank.fromJson(e)).toList();
  }

  Future insertBank(Bank bank) async {
    final url = Uri.parse("${GlobalData.url}/bank/insert");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(bank.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception(
        '요청 실패 ${response.statusCode}: ${utf8.decode(response.bodyBytes)}',
      );
    }
    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshBank();
    return data['result'];
  }

  Future<String> updateBank(Bank bank) async {
    final url = Uri.parse("${GlobalData.url}/bank/update");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(bank.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception(
        '요청 실패 ${response.statusCode}: ${utf8.decode(response.bodyBytes)}',
      );
    }
    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshBank();
    return data['result'];
  }

  Future<void> refreshBank() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => fetchBank());
  }
}

final bankNotifier = AsyncNotifierProvider<BankNotifier,List<Bank>>(
  BankNotifier.new
);