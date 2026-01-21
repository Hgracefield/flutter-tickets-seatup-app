import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seatup_app/view/user/payment.dart';
import 'package:seatup_app/vm/post_notifier.dart';
import 'package:seatup_app/vm/user_notifier.dart'; // 유저 정보 가져오기

class TicketDetail extends ConsumerWidget {
  final int postSeq;
  const TicketDetail({super.key, required this.postSeq});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(postDetailProvider(postSeq));
    final userAsync = ref.watch(userNotifierProvider); // 구매자(나) 정보
    final Color accentColor = const Color(0xFFF8DE7D);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("티켓 상세 정보", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
        centerTitle: true,
      ),
      body: detailAsync.when(
        data: (post) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow("공연명", post.curtain_title ?? "정보 없음"),
                      const SizedBox(height: 10),
                      Text("거래 금액: ${NumberFormat('#,###').format(post.post_price)}원", 
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange)),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 20),
                      const Text("판매자 설명", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(post.post_desc, style: const TextStyle(fontSize: 15, height: 1.5)),
                    ],
                  ),
                ),
              ),
              // --- 하단 결제 버튼 ---
              Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                child: ElevatedButton(
                  onPressed: () {
                    // 결제 페이지로 이동하며 실제 데이터를 넘겨줌
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentPage(
                          post: post, 
                          buyerId: userAsync.value?.user_id ?? 0,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor, foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text("안전 결제하기", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("정보를 가져오는데 실패했습니다: $e")),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(width: 10),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}