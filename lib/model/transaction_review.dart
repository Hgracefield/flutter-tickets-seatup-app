import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionReview {
  final int post_seq;       // 거래 티켓 번호
  final int reviewer_id;    // 후기 작성자 (나)
  final int reviewee_id;    // 후기 대상자 (상대방)
  final List<int> tags;     // 선택한 매너 태그 번호들
  final String content;     // 상세 후기
  final DateTime? created_at;

  TransactionReview({
    required this.post_seq,
    required this.reviewer_id,
    required this.reviewee_id,
    required this.tags,
    required this.content,
    this.created_at,
  });

  factory TransactionReview.fromFirestore(Map<String, dynamic> json) {
    return TransactionReview(
      post_seq: json['post_seq'] ?? 0,
      reviewer_id: json['reviewer_id'] ?? 0,
      reviewee_id: json['reviewee_id'] ?? 0,
      tags: List<int>.from(json['tags'] ?? []),
      content: json['content'] ?? "",
      created_at: (json['created_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'post_seq': post_seq,
      'reviewer_id': reviewer_id,
      'reviewee_id': reviewee_id,
      'tags': tags,
      'content': content,
      'created_at': FieldValue.serverTimestamp(),
    };
  }
}