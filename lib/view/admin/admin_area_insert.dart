import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/area.dart';
import 'package:seatup_app/util/message.dart';
import 'package:seatup_app/vm/area_notifier.dart';

class AdminAreaInsert extends ConsumerStatefulWidget {
  const AdminAreaInsert({super.key});

  @override
  ConsumerState<AdminAreaInsert> createState() => _AdminAreaInsertState();
}

class _AdminAreaInsertState extends ConsumerState<AdminAreaInsert> {
  // === Property ===
  late TextEditingController numberController;
  late TextEditingController valueController;

  Message message = Message();

  @override
  void initState() {
    super.initState();
    numberController = TextEditingController();
    valueController = TextEditingController();
  }

  @override
  void dispose() {
    numberController.dispose();
    valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('구역 등록')),
      body: Center(
        child: Column(
          children: [
            _buildTextField('구역 등급', numberController, false),
            _buildTextField('구역 가치', valueController, false),
            ElevatedButton(
              onPressed: () async {
                if (numberController.text.trim().isEmpty ||
                    valueController.text.trim().isEmpty) {
                  message.errorSnackBar(context, '비어 있는 칸이 있습니다');
                } else {
                  insert();
                }
              },
              child: Text('추가하기'),
            ),
          ],
        ),
      ),
    );
  } // build

  // === Widgets ===

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    bool readOnly,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  } // _buildTextField

  // === Functions ===

  Future insert() async {
    final gradeNotifier = ref.watch(areaNotifierProvider.notifier);

    Area grade = Area(
      area_number: numberController.text.trim(),
      area_value: int.parse(valueController.text.trim()),
    );
    final result = await gradeNotifier.updateUser(grade);
    if (result == 'OK') {
      if (!mounted) return;
      message.successSnackBar(context, '구역이 추가 되었습니다.');
    }
  }
} // class
