import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seatup_app/model/faq.dart';

class FaqRepository {
  final FirebaseFirestore _db;
  FaqRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('FAQs');

  Stream<List<Faq>> watchFaqs() {
    return _col
        .orderBy('no', descending: false)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => Faq.fromMap(d.data(), d.id))
              .toList(),
        );
  }

  Future<Faq?> fetchById(String id) async {
    final doc = await _col.doc(id).get();
    final data = doc.data();
    if (data == null) return null;
    return Faq.fromMap(data, doc.id);
  }

  Future<void> insert({
    required int no,
    required String title,
    required String contents,
  }) async {
    await _col.add({
      'no': no,
      'title': title,
      'contents': contents,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> update({
    required String id,
    required String title,
    required String contents,
  }) async {
    await _col.doc(id).update({
      'title': title,
      'contents': contents,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }
}
