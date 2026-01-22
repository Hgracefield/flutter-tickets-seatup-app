import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seatup_app/vm/sell_history_notifier.dart';
import 'package:seatup_app/vm/user_notifier.dart';
import 'transaction_review_write.dart';

class SellHistory extends ConsumerStatefulWidget {
  const SellHistory({super.key});

  @override
  ConsumerState<SellHistory> createState() => _SellHistoryState();
}

class _SellHistoryState extends ConsumerState<SellHistory> {
  final Color accentColor = const Color(0xFFF8DE7D);
  final Color bgGrey = const Color(0xFFF8F8F8);

  @override
  void initState() {
    super.initState();
    // 1. 화면 진입 시 내 ID를 가져와서 판매 내역 로드
    Future.microtask(() {
      final myId = ref.read(userNotifierProvider).value?.user_id ?? 0;
      if (myId != 0) {
        ref.read(sellHistoryProvider.notifier).fetchHistory(myId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(sellHistoryProvider);
    final myId = ref.watch(userNotifierProvider).value?.user_id ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "판매 내역",
          style: TextStyle(
            fontSize: 22, // 가이드라인 반영 (Title 22sp)
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: historyAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text("판매 완료된 내역이 없습니다.", style: TextStyle(fontSize: 14, color: Colors.grey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // 가이드라인 (16dp)
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return _buildHistoryCard(item, myId);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("데이터 로드 실패: $e")),
      ),
    );
  }

  // 개별 내역 카드 위젯
  Widget _buildHistoryCard(Map<String, dynamic> item, int myId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24), // 가이드라인 (Section ↔ Section 24dp)
      padding: const EdgeInsets.all(16), // 가이드라인 (16dp)
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 티켓 제목 (Subtitle 16sp)
          Text(
            item['title'] ?? "티켓 정보 없음",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          
          // 2. 가격 및 수량 정보 (Body 14sp)
          Text(
            "${NumberFormat('#,###').format(item['price'])}원 · ${item['quantity']}매",
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          
          // 3. 거래 날짜 (Caption 12sp)
          Text(
            "거래일: ${item['date']}",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          
          const SizedBox(height: 16), // 가이드라인 (Content ↔ Content 16dp)
          const Divider(height: 1),
          const SizedBox(height: 16),

          // 4. 하단 액션 버튼 섹션
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "거래 완료",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              // 평가하기 버튼 (Button 가이드라인 반영)
              SizedBox(
                height: 48, // 가이드라인 (Height 48dp)
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionReviewWrite(
                          postSeq: item['post_seq'],
                          sellerId: item['buyer_id'], // 판매 내역에서는 '구매자'가 평가 대상이 됨
                          reviewerId: myId,          // 작성자는 '나(판매자)'
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16), // 가이드라인 (16dp)
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // 가이드라인 (Radius 8dp)
                    ),
                  ),
                  child: const Text(
                    "구매자 평가하기",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), // 가이드라인 (14sp)
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
  );
}