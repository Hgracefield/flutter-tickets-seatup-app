// Firestore 컬렉션 Provider

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:seatup_app/model/faq.dart';

final faqsCollectionProvider = Provider<CollectionReference<Map<String, dynamic>>>(
  (ref) => FirebaseFirestore.instance.collection('FAQs'),
);
// 체크 박스
final faqselectedProvider = StateProvider<String?>((ref) => null);
// 확장 액션
final faqExpandedProvider = StateProvider<String?>((ref) => null);
// 실시간 Faq 목록 Provider(streamProvider)
final faqListProvider = StreamProvider<List<Faq>>((ref) {
  final col = ref.watch(faqsCollectionProvider);

  return col.orderBy('createdAt', descending: false).snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => Faq.fromMap(doc.data(), doc.id)).toList();
  });
});

// Faq 액션 Provider (입력, 수정, 삭제)
class FaqActionNotifier extends Notifier<void> {
  @override
  void build() {}

  CollectionReference<Map<String, dynamic>> get _faqs => ref.read(faqsCollectionProvider);
  Future<void> addFaq({required String title, required String contents}) async {
    await _faqs.add({'title': title, 'contents': contents, 'createdAt': Timestamp.now()});
  }

  Future<void> deleteFaq(String id) async {
    await _faqs.doc(id).delete();
  }

  Future<void> updateFaq({
    required String id,
    required String title,
    required String contents,
  }) async {
    await _faqs.doc(id).update({
      'title': title,
      'contents': contents,
      'createdAt': Timestamp.now(),
    });
  }
}

final faqActionProvider = NotifierProvider<FaqActionNotifier, void>(
  FaqActionNotifier.new,
);

// (옵션) 수정 페이지에서 단건 불러오기 Provider
final faqByIdProvider = FutureProvider.family<Faq?, String>((ref, id) async {
  final doc = await ref.watch(faqsCollectionProvider).doc(id).get();
  final data = doc.data();
  if (data == null) return null;
  return Faq.fromMap(data, doc.id);
});
