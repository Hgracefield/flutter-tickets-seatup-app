import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/bank.dart';
import 'package:seatup_app/util/message.dart';
import 'package:seatup_app/vm/bank_notifier.dart';

class AdminBankInsert extends ConsumerStatefulWidget {
  const AdminBankInsert({super.key});

  @override
  ConsumerState<AdminBankInsert> createState() => _AdminBankInsertState();
}

class _AdminBankInsertState extends ConsumerState<AdminBankInsert> {
  // === Property ===
  late TextEditingController nameController;

  Message message = Message();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('은행 등록')),
      body: Center(
        child: Column(
          children: [
            _buildTextField('은행 이름', nameController, false),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
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
    final bankNotifierProvider = ref.watch(bankNotifier.notifier);

    Bank grade = Bank(
      bank_seq: 0,
      bank_name: nameController.text.trim(),
      bank_create_date: ''
    );
    final result = await bankNotifierProvider.insertBank(grade);
    if (result == 'OK') {
      if (!mounted) return;
      message.successSnackBar(context, '은행이 추가 되었습니다.');
    }
  }
} // class
