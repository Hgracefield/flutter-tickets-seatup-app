import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

/*
  - User , Staff가 사용하는 GetStorage Provider
  - 사용방법
    1) class StaffProvider extends AsyncNotifier<List<Staff>> {
          late final GetStorage box;

          @override
          FutureOr<List<Staff>> build() async {
            box = ref.read(storageProvider); // 주입
            return fetchStaff();
        }

        Future<void> saveLogin(Staff staff) async {
          box.write('role', 'staff');
          box.write('staff_seq', staff.staffSeq);
          box.write('staff_name', staff.staffName);
        }
}
    2) 읽기 
      final staffSeq = ref.read(storageProvider).read('staff_seq'); <- 이런식으로사용한다.
*/

final storageProvider = Provider<GetStorage>((ref) {
  return GetStorage();
});