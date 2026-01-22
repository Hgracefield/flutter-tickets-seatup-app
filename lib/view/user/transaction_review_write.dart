import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/transaction_review.dart';
import 'package:seatup_app/vm/transaction_review_notifier.dart';
import 'package:seatup_app/vm/user_notifier.dart';

class TransactionReviewWrite extends ConsumerStatefulWidget {
  final int postSeq;
  final int sellerId;
  final int reviewerId; // [추가] 구매자 ID를 직접 받음

  const TransactionReviewWrite({
    super.key, 
    required this.postSeq, 
    required this.sellerId,
    required this.reviewerId, // 필수 인자로 추가
  });

  @override
  ConsumerState<TransactionReviewWrite> createState() => _TransactionReviewWriteState();
}

class _TransactionReviewWriteState extends ConsumerState<TransactionReviewWrite> {
  final List<int> _selectedTags = [];
  final TextEditingController _contentController = TextEditingController();
  final Color accentColor = const Color(0xFFF8DE7D);

  final Map<int, String> _tagMap = {
    1: "응답이 빨라요",
    2: "친절하고 매너있어요",
    3: "시간 약속을 잘 지켜요",
    4: "티켓 정보가 정확해요",
    5: "기분 좋은 거래였어요",
  };

  @override
  Widget build(BuildContext context) {
    // 이제 build 안에서 프로바이더를 통해 myId를 찾을 필요가 없습니다. (전달받은 값 사용)
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("거래 후기 작성"), backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("이번 거래, 어떠셨나요?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              children: _tagMap.entries.map((entry) {
                final isSelected = _selectedTags.contains(entry.key);
                return GestureDetector(
                  onTap: () => setState(() => isSelected ? _selectedTags.remove(entry.key) : _selectedTags.add(entry.key)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? accentColor : const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(entry.value, style: TextStyle(color: Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            const Text("상세한 후기를 남겨주세요", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: InputDecoration(hintText: "따뜻한 후기를 남겨주세요.", filled: true, fillColor: const Color(0xFFF8F8F8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _selectedTags.isEmpty ? null : () async {
                final review = TransactionReview(
                  post_seq: widget.postSeq,
                  reviewer_id: widget.reviewerId, // [수정] 전달받은 ID 사용
                  reviewee_id: widget.sellerId,
                  tags: _selectedTags,
                  content: _contentController.text,
                );
                final success = await ref.read(transactionReviewProvider.notifier).addReview(review);
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("후기가 등록되었습니다!")));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
              child: const Text("작성 완료", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}