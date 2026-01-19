import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/grade.dart';
import 'package:seatup_app/util/message.dart';
import 'package:seatup_app/vm/grade_notifier.dart';

class AdminGradeInsert extends ConsumerStatefulWidget {
  const AdminGradeInsert({super.key});

  @override
  ConsumerState<AdminGradeInsert> createState() => _AdminGradeInsertState();
}

class _AdminGradeInsertState extends ConsumerState<AdminGradeInsert> {
  // === Property ===
  late TextEditingController nameController;
  late TextEditingController valueController;

  Message message = Message();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    valueController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('좌석 등급 등록')),
      body: Center(
        child: Column(
          children: [
            _buildTextField('좌석 등급', nameController, false),
            _buildTextField('좌석 가치', valueController, false),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty ||
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
    final gradeNotifier = ref.watch(gradeNotifierProvider.notifier);

    Grade grade = Grade(
      grade_name: nameController.text.trim(),
      grade_value: int.parse(valueController.text.trim()),
    );
    final result = await gradeNotifier.updateUser(grade);
    if (result == 'OK') {
      if (!mounted) return;
      message.successSnackBar(context, '좌석 등급이 추가 되었습니다.');
    }
  }
} // class
