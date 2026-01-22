import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/view/admin/admin_bank_insert.dart';
import 'package:seatup_app/view/admin/admin_bank_update.dart';
import 'package:seatup_app/vm/bank_notifier.dart';

class AdminBankQuery extends ConsumerWidget {
  const AdminBankQuery({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
   final bankAsync = ref.watch(bankNotifier);
    return Scaffold(
      appBar: AppBar(
        title: Text('구역'),
        actions: [ IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminBankInsert()),
            ),
          ),],
      ),
      body: bankAsync.when(
        data: (banks) {
          return banks.isEmpty
          ? const Center(child: Text('구역 정보가 없습니다'))
          : ListView.builder(
              itemCount: banks.length,
              itemBuilder: (context, index) {
                final bank = banks[index];
                return ListTile(
                  title: Text('${bank.bank_name}'),
                  subtitle: Text('${bank.bank_seq}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>AdminBankUpdate(
                          seq: bank.bank_seq!,
                          name: bank.bank_name,
                          date: bank.bank_create_date!,
                        ),
                      ),
                    );
                  },
                );
              },
            );
        }, 
        error: (error, stackTrace) => Center(child: Text('오류 발생 : $error'),), 
        loading: () => Center(child: CircularProgressIndicator(),),)
    );
  }
} // class
