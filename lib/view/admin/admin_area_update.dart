import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/area.dart';
import 'package:seatup_app/util/message.dart';
import 'package:seatup_app/vm/area_notifier.dart';

class AdminAreaUpdate extends ConsumerStatefulWidget {
  final int seq;
  final String name;
  final int value;
  final String date;
  const AdminAreaUpdate({
    super.key,
    required this.seq,
    required this.name,
    required this.value,
    required this.date,
  });

  @override
  ConsumerState<AdminAreaUpdate> createState() => _AdminAreaUpdateState();
}

class _AdminAreaUpdateState extends ConsumerState<AdminAreaUpdate> {
  // === Property ===
  late TextEditingController seqController;
  late TextEditingController nameController;
  late TextEditingController valueController;

  Message message = Message();

  @override
  void initState() {
    super.initState();
    seqController = TextEditingController();
    nameController = TextEditingController();
    valueController = TextEditingController();
    seqController.text = widget.seq.toString();
    nameController.text = widget.name;
    valueController.text = widget.value.toString();
  }

  @override
  void dispose() {
    seqController.dispose();
    nameController.dispose();
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
            _buildTextField('번호', seqController, true),
            _buildTextField('Number', seqController, false),
            _buildTextField('Value', seqController, false),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty ||
                    valueController.text.trim().isEmpty) {
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
    final gradeNotifier = ref.watch(areaNotifierProvider.notifier);

    Area grade = Area(
      area_seq: int.parse(seqController.text),
      area_number: nameController.text.trim(),
      area_value: int.parse(valueController.text.trim()),
    );
    final result = await gradeNotifier.updateUser(grade);
    if (result == 'OK') {
      if (!mounted) return;
      message.successSnackBar(context, '구역 수정이 완료 되었습니다');
    }
  }
} // class
