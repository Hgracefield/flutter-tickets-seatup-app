import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:seatup_app/model/staff.dart';
import 'package:seatup_app/util/global_data.dart';
import 'package:http/http.dart' as http;
import 'package:seatup_app/vm/storage_provider.dart';

class DashBoardState {
  final int selectedMenuIndex;
  final List<Staff> staffList;

  DashBoardState({this.selectedMenuIndex = 0, required this.staffList});

  DashBoardState copyWith({int? selectedMenuIndex, List<Staff>? staffList}) {
    return DashBoardState(
      selectedMenuIndex: selectedMenuIndex ?? this.selectedMenuIndex,
      staffList: staffList ?? this.staffList,
    );
  }
}

class StaffNotifier extends AsyncNotifier<DashBoardState> {
  final String baseUrl = GlobalData.url;
  late final GetStorage box;

  @override
  FutureOr<DashBoardState> build() async {
    box = ref.read(storageProvider);
    return await fetchStaff();
  }

  // 관리자 seq , name 저장소
  Future<void> saveLogin(Map<String, dynamic> staff) async {
    box.write('staffIsLogin', true); // 관리자 로그인
    box.write('staff_seq', staff['staff_seq']); // 관리자 seq
    box.write('staff_name', staff['staff_name']); // 관리자 이름

    // print('=== GetStorage staff login saved ===');
    // print('staffIsLogin: ${box.read('staffIsLogin')}');
    // print('staff_seq    : ${box.read('staff_seq')}');
    // print('staff_name   : ${box.read('staff_name')}');
  }
  // Get Storage 로그아웃
  Future<void> logout() async {
  box.remove('staffIsLogin');
  box.remove('staff_seq');
  box.remove('staff_name');
}


  // select(state.staffList)
  Future<DashBoardState> fetchStaff() async {
    final res = await http.get(Uri.parse("$baseUrl/staff/select"));

    if (res.statusCode != 200) {
      throw Exception("불러오기 실패: ${res.statusCode}");
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    final staffList = (data['results'] as List)
        .map((e) => Staff.fromJson(e))
        .toList();
    return DashBoardState(staffList: staffList);
  }

  // CheckLogin for staff
  Future<List<dynamic>> loginCheckStaff(String id, String pwd) async {
    final url = Uri.parse('$baseUrl/staff/staffLogin');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'staff_email': id, 'staff_password': pwd},
    );

    final data = json.decode(utf8.decode(response.bodyBytes));
    return data['results'];
  }

  // delete
  Future<String> deleteStaff(String code) async {
    final url = Uri.parse('$baseUrl/staff/delete');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'code': code}),
    );
    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshStaff();
    return data['result'];
  }

  Future<void> refreshStaff() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => await fetchStaff());
  }

  void setMenuIndex(int index) {
    final current = state.value;
    if (current == null) {
      return;
    }

    state = AsyncData(current.copyWith(selectedMenuIndex: index));
  }
} // StaffNotifier

final staffNotifierProvider =
    AsyncNotifierProvider<StaffNotifier, DashBoardState>(StaffNotifier.new);
