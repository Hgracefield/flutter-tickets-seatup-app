import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seatup_app/vm/post_notifier.dart';
import 'package:seatup_app/vm/payment_notifier.dart';

class TicketResultScreen extends ConsumerWidget {
  const TicketResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postNotifierProvider);
    final pState = ref.watch(paymentProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("검색 결과"), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: postAsync.when(
        data: (list) => list.isEmpty 
          ? const Center(child: Text("결과 없음")) 
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: list.length,
              itemBuilder: (c, i) => Card(child: ListTile(title: Text("${list[i].post_quantity}매"), subtitle: Text(list[i].post_desc ?? ""), trailing: Text("${list[i].post_price}원"))),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("에러: $e")),
      ),
    );
  }
}