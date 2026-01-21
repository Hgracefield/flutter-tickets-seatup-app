import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/address.dart';

class AddressRepository {
  AddressRepository(this.baseUrl);

  final String baseUrl;

  Future<UserAddress> fetchUserAddress(int userId) async {
    final url = Uri.parse('$baseUrl/user/address/$userId');
    final res = await http.get(url);

    if (res.statusCode != 200) {
      throw Exception('유저 주소 호출 실패: ${res.statusCode}\n${res.body}');
    }

    final data = jsonDecode(res.body);

    if (data['result'] != 'OK') {
      throw Exception('유저 주소 응답 Error: ${res.body}');
    }

    return UserAddress.fromJson(data);
  }

  Future<PlaceAddress> fetchPlace(int placeSeq) async {
    final url = Uri.parse('$baseUrl/place/select/$placeSeq');
    final res = await http.get(url);

    if (res.statusCode != 200) {
      throw Exception('공연장 호출 실패: ${res.statusCode}\n${res.body}');
    }

    final data = jsonDecode(res.body);

    if (data['result'] != 'OK') {
      throw Exception('공연장 응답 Error: ${res.body}');
    }

    return PlaceAddress.fromJson(data);
  }
}
