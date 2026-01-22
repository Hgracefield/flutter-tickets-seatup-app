import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/transaction_review.dart';

class TransactionReviewNotifier extends AsyncNotifier<List<TransactionReview>> {
  @override
  FutureOr<List<TransactionReview>> build() async => [];

  // 후기 등록
  Future<bool> addReview(TransactionReview review) async {
    try {
      await FirebaseFirestore.instance
          .collection('transaction_reviews')
          .add(review.toFirestore());
      return true;
    } catch (e) {
      return false;
    }
  }

  // 특정 유저가 받은 후기 목록 실시간 로드
  void fetchReviews(int userId) {
    state = const AsyncLoading();
    FirebaseFirestore.instance
        .collection('transaction_reviews')
        .where('reviewee_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen((snapshot) {
      final reviews = snapshot.docs
          .map((doc) => TransactionReview.fromFirestore(doc.data()))
          .toList();
      state = AsyncValue.data(reviews);
    });
  }
}

final transactionReviewProvider =
    AsyncNotifierProvider<TransactionReviewNotifier, List<TransactionReview>>(
  TransactionReviewNotifier.new,
);