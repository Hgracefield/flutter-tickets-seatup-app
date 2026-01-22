import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/bank.dart';
import 'package:seatup_app/util/message.dart';
import 'package:seatup_app/vm/bank_notifier.dart';

class AdminBankUpdate extends ConsumerStatefulWidget {
  final int seq;
  final String name;
  final String date;
  const AdminBankUpdate({
    super.key, 
    required this.seq,
    required this.name,
    required this.date});

  @override
  ConsumerState<AdminBankUpdate> createState() => _AdminBankUpdateState();
}

class _AdminBankUpdateState extends ConsumerState<AdminBankUpdate> {
 // === Property ===
  late TextEditingController seqController;
  late TextEditingController nameController;

  Message message = Message();

  @override
  void initState() {
    super.initState();
    seqController = TextEditingController();
    nameController = TextEditingController();
    seqController.text = widget.seq.toString();
    nameController.text = widget.name;
  }

  @override
  void dispose() {
    seqController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('은행 수정')),
      body: Center(
        child: Column(
          children: [
            _buildTextField('번호', seqController, true),
            _buildTextField('이름', nameController, false),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty)
                {
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
    final gradeNotifier = ref.watch(bankNotifier.notifier);

    Bank bank = Bank(
      bank_seq: int.parse(seqController.text),
      bank_name: nameController.text.trim(),
      bank_create_date: ''
    );
    final result = await gradeNotifier.updateBank(bank);
    if (result == 'OK') {
      if (!mounted) return;
      message.successSnackBar(context, '구역 수정이 완료 되었습니다');
    }
  }
} // class
