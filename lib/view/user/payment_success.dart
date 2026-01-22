import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seatup_app/model/post.dart';
import 'transaction_review_write.dart'; 

class PaymentSuccessPage extends StatelessWidget {
  final Post post;
  final int buyerId;

  const PaymentSuccessPage({super.key, required this.post, required this.buyerId});

  @override
  Widget build(BuildContext context) {
    final Color accentColor = const Color(0xFFF8DE7D);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            const Center(child: Icon(Icons.check_circle, size: 90, color: Color(0xFF4CAF50))),
            const SizedBox(height: 24),
            const Text("결제가 성공적으로\n완료되었습니다!", textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 25),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFFF8F8F8), borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _infoRow("상품명", post.curtain_title ?? "티켓"),
                  const SizedBox(height: 12),
                  _infoRow("결제 금액", "${NumberFormat('#,###').format(post.post_price)}원"),
                  const Divider(height: 30),
                  _infoRow("판매자", "${post.user_name ?? '익명'} 님"),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text("거래는 만족스러우셨나요?\n판매자에게 따뜻한 후기를 남겨주세요!", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransactionReviewWrite(
                            postSeq: post.post_seq!,
                            sellerId: post.post_user_id,
                            reviewerId: buyerId, // [수정] 이 정보를 넘겨줘야 0으로 안나옵니다.
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                    child: const Text("거래 후기 남기기", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                    child: const Text("홈으로 돌아가기", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }
}