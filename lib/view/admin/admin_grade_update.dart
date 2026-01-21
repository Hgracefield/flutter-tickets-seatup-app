import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/grade.dart';
import 'package:seatup_app/util/message.dart';
import 'package:seatup_app/vm/grade_notifier.dart';

class AdminGradeUpdate extends ConsumerStatefulWidget {
  final int seq;
  final String name;
  final int value;
  final String date;
  final int price;
  const AdminGradeUpdate({
    super.key,
    required this.seq,
    required this.name,
    required this.value,
    required this.date,
    required this.price
  });

  @override
  ConsumerState<AdminGradeUpdate> createState() => _AdminGradeUpdateState();
}

class _AdminGradeUpdateState extends ConsumerState<AdminGradeUpdate> {
  // === Property ===
  late TextEditingController seqController;
  late TextEditingController nameController;
  late TextEditingController valueController;
  late TextEditingController priceController;

  Message message = Message();

  @override
  void initState() {
    super.initState();
    seqController = TextEditingController();
    nameController = TextEditingController();
    valueController = TextEditingController();
    priceController = TextEditingController();

    seqController.text = widget.seq.toString();
    nameController.text = widget.name;
    valueController.text = widget.value.toString();
    priceController.text = widget.price.toString();

  }

  @override
  void dispose() {
    seqController.dispose();
    nameController.dispose();
    valueController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('좌석 등급 등록')),
      body: Center(
        child: Column(
          children: [
            _buildTextField('번호', seqController, true),
            _buildTextField('좌석 등급', nameController, false),
            _buildTextField('좌석 가치', valueController, false),
            _buildTextField('가격', priceController, false),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty ||
                    valueController.text.trim().isEmpty ||
                    priceController.text.trim().isEmpty
                    ) {
                  message.errorSnackBar(context, '비어 있는 칸이 있습니다');
                } else {
                  update();
                }
              },
              child: Text('수정하기'),
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

  Future update() async {
    final gradeNotifier = ref.watch(gradeNotifierProvider.notifier);

    Grade grade = Grade(
      grade_seq: int.parse(seqController.text),
      grade_name: nameController.text.trim(),
      grade_value: int.parse(valueController.text.trim()),
      grade_price: int.parse(priceController.text.trim())
    );
    final result = await gradeNotifier.updateGrade(grade);
    if (result == 'OK') {
      if (!mounted) return;
      message.successSnackBar(context, '좌석 등급 수정이 완료 되었습니다');
    }
  }
} // class
