import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/place.dart';
import 'package:seatup_app/util/global_data.dart';
import 'package:http/http.dart' as http;

class PlaceNotifier extends AsyncNotifier<List<Place>>{
  @override
  FutureOr<List<Place>> build() async{
    return await fetchPlace();
  }

  Future<List<Place>> fetchPlace() async {
    String url = "${GlobalData.url}/place/select";
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) {
      throw Exception('불러오기 실패 ${res.statusCode}');
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    return (data['results'] as List).map((e) => Place.fromJson(e)).toList();
  }

  Future insertPlace(Place place) async {
    final url = Uri.parse("${GlobalData.url}/place/insert");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(place.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception(
        '요청 실패 ${response.statusCode}: ${utf8.decode(response.bodyBytes)}',
      );
    }
    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshPlace();
    return data['result'];
  }

  Future<String> updatePlace(Place place) async {
    final url = Uri.parse("${GlobalData.url}/place/update");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(place.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception(
        '요청 실패 ${response.statusCode}: ${utf8.decode(response.bodyBytes)}',
      );
    }
    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshPlace();
    return data['result'];
  }

  Future<void> refreshPlace() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => fetchPlace());
  }
}
final placeNotifierProvider = AsyncNotifierProvider<PlaceNotifier, List<Place>>(
  PlaceNotifier.new
);