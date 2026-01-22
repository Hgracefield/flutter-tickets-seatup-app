import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/curtain_review.dart';

// Firebase 컬렉션 Provider
final reviewsCollectionProvider = Provider<CollectionReference>(
  (ref) => FirebaseFirestore.instance.collection('curtain_reviews'),
);

// 실시간 관람 후기 목록 Provider(StreamProvider)
final reviewListProvider = StreamProvider<List<CurtainReview>>((ref) {
  final col = ref.watch(reviewsCollectionProvider);
  return col.snapshots().map((snapshot) {
    return snapshot.docs
        .map((doc) => CurtainReview.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  });
});

// 관람 후기 액션 Provider(추가, 삭제)
class ReviewActionNotifier extends Notifier<void> {
  
  @override
  void build() {}

  CollectionReference get _reviews => ref.read(reviewsCollectionProvider);


  Future<void> addReview(String title, String content) async {
    await _reviews.add({'title': title, 'content': content});
  }

  Future<void> deleteReview(String id) async {
    await _reviews.doc(id).delete();
  }
}

final reviewActionProvider = NotifierProvider<ReviewActionNotifier, void>(
  ReviewActionNotifier.new,
);
