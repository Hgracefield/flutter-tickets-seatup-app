import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seatup_app/vm/transaction_review_notifier.dart';

class TransactionReviewList extends ConsumerStatefulWidget {
  final int userId;
  const TransactionReviewList({super.key, required this.userId});

  @override
  ConsumerState<TransactionReviewList> createState() => _TransactionReviewListState();
}

class _TransactionReviewListState extends ConsumerState<TransactionReviewList> {
  final Map<int, String> _tagMap = { 1: "응답이 빨라요", 2: "친절하고 매너있어요", 3: "시간 약속을 잘 지켜요", 4: "티켓 정보가 정확해요", 5: "기분 좋은 거래였어요" };

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(transactionReviewProvider.notifier).fetchReviews(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    final reviewAsync = ref.watch(transactionReviewProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("거래 후기"), backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black, centerTitle: true),
      body: reviewAsync.when(
        data: (reviews) {
          if (reviews.isEmpty) return const Center(child: Text("아직 받은 후기가 없습니다."));
          
          // 태그 통계 계산
          Map<int, int> stats = {};
          for (var r in reviews) { for (var t in r.tags) { stats[t] = (stats[t] ?? 0) + 1; } }
          var sortedStats = stats.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text("받은 매너 평가", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              ...sortedStats.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(children: [
                  const Icon(Icons.face, size: 20, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_tagMap[e.key] ?? "기타")),
                  Text("${e.value}", style: const TextStyle(fontWeight: FontWeight.bold)),
                ]),
              )),
              const Divider(height: 40),
              const Text("상세 거래 후기", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              ...reviews.where((r) => r.content.isNotEmpty).map((r) => Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: const Color(0xFFF8F8F8), borderRadius: BorderRadius.circular(12)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r.content, style: const TextStyle(fontSize: 14, height: 1.4)),
                  const SizedBox(height: 10),
                  Text(r.created_at != null ? DateFormat('yyyy.MM.dd').format(r.created_at!) : "", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ]),
              )),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("에러: $e")),
      ),
    );
  }
}