import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seatup_app/vm/post_notifier.dart';
import 'package:seatup_app/vm/payment_notifier.dart';
import 'ticket_detail.dart'; 

class TicketResultScreen extends ConsumerWidget {
  const TicketResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postNotifierProvider);
    final pState = ref.watch(paymentProvider);
    final Color accentColor = const Color(0xFFF8DE7D);
    final Color bgGrey = const Color(0xFFF8F8F8);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("거래 가능한 티켓", style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 상단 선택 조건 요약 바
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            color: bgGrey,
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.black54),
                const SizedBox(width: 8),
                Text(
                  "${pState.selectedDate != null ? DateFormat('MM.dd').format(pState.selectedDate!) : ''} | ${pState.selectedTime} | ${pState.selectedRow}",
                  style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Expanded(
            child: postAsync.when(
              data: (list) {
                if (list.isEmpty) return const Center(child: Text("조건에 맞는 판매글이 없습니다."));
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final post = list[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TicketDetail(postSeq: post.post_seq!),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("${pState.selectedRow} ${post.post_quantity}매", 
                                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black)),
                                Text("${NumberFormat('#,###').format(post.post_price)}원", 
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(post.post_desc, 
                              style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4), 
                              maxLines: 2, 
                              overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Color(0xFFF0F0F0),
                                  child: Icon(Icons.person, size: 14, color: Colors.grey),
                                ),
                                const SizedBox(width: 8),
                                // [수정] 실제 판매자 이름을 표시
                                Text(
                                  "${post.user_name ?? '익명'} 님", 
                                  style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold)
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(8)),
                                  child: const Text("상세보기", 
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text("에러: $e")),
            ),
          ),
        ],
      ),
    );
  }
}