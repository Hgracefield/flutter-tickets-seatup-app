import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/user.dart';
import 'package:seatup_app/util/global_data.dart';
import 'package:seatup_app/util/login_status.dart';

class UserNotifier extends AsyncNotifier<User>{

  @override
  Future<User> build() async {
      return await fetchUser();
  }

  Future<User> fetchUser() async {
    // isLoading = true;
    // error = null;

    final res = await http.get(Uri.parse("${GlobalData.url}/user/select"));
    if (res.statusCode != 200) {
      throw Exception('불러오기 실패 ${res.statusCode}');
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    User user = User.fromJson(data['result']);
    return user;
    // data['result'];
    // return data['result'];
    // return (data['results'] as List).map((d) => User.fromJson(d)).toList();
  }

  Future<LoginStatus> login(String email, String password) async {
  final url = Uri.parse('${GlobalData.url}/user/login');
  final res = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'email': email, 'password': password}),
  );

  if (res.statusCode != 200) return LoginStatus.fail;

  // 서버가 세션/토큰을 세팅하고 /user/select가 성공한다는 전제
  await refreshUser();
  return LoginStatus.success;
  }

  Future<int> existUser(String email) async {
    final url = Uri.parse("${GlobalData.url}/user/exist");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email
      }),
    );
    if (response.statusCode != 200) {
  throw Exception('요청 실패 ${response.statusCode}: ${utf8.decode(response.bodyBytes)}');
}
    final data = json.decode(utf8.decode(response.bodyBytes));
    return data['result'];
  }

  Future<String> insertUser(User user) async{
  final url = Uri.parse("${GlobalData.url}/user/insert");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user.toJson()),
    );
    if (response.statusCode != 200) {
  throw Exception('요청 실패 ${response.statusCode}: ${utf8.decode(response.bodyBytes)}');
}
    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshUser();
    return data['result'];
  }

  Future<String> updateUser(User s) async {
    final url = Uri.parse("${GlobalData.url}/user/update");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(s.toJson()),
    );
    if (response.statusCode != 200) {
  throw Exception('요청 실패 ${response.statusCode}: ${utf8.decode(response.bodyBytes)}');
}
    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshUser();
    return data['result'];
  }

  Future<String> withdrawUser(int user) async{
    final url = Uri.parse("${GlobalData.url}/user/withdraw?user=$user");
    final response = await http.get(url);
    if (response.statusCode != 200) {
  throw Exception('요청 실패 ${response.statusCode}: ${utf8.decode(response.bodyBytes)}');
}
    final data = json.decode(utf8.decode(response.bodyBytes));
    return data['result'];
  }

  Future<void> refreshUser() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => fetchUser());
  }
}

final userNotifierProvider = AsyncNotifierProvider<UserNotifier,User>(
  UserNotifier.new  
);


// class UserState{
//   final int user_id;
//   final String user_email;
//   final String user_password;
//   final String user_name;
//   final String user_phone;
//   final String user_address;
//   final String user_bank_name;
//   final String user_account;

//   UserState({
//     this.user_id = 0,
//     this.user_email = "",
//     this.user_password = "",
//     this.user_name = "",
//     this.user_phone = "",
//     this.user_address = "",
//     this.user_bank_name = "",
//     this.user_account = "",
//   });
//   UserState copyWith({
//     int? user_id,
//     String? user_email,
//     String? user_password,
//     String? user_name,
//     String? user_phone,
//     String? user_address,
//     String? user_bank_name,
//     String? user_account
//   })
//   {
//     return UserState(
//       user_id: user_id ?? this.user_id,
//       user_email: user_email ?? this.user_email,
//       user_password: user_password ?? this.user_password,
//       user_name: user_name ?? this.user_name,
//       user_phone: user_phone ?? this.user_phone,
//       user_address: user_address ?? this.user_address,
//       user_bank_name: user_bank_name ?? this.user_bank_name,
//       user_account: user_account ?? this.user_account
//     );
//   }
// }