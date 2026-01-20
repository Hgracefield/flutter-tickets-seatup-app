import 'package:cloud_firestore/cloud_firestore.dart';

class Faq {
  final String id; // 문서 id
  final String title;
  final String contents;
  final DateTime? createdAt;

  Faq({required this.id, required this.title, required this.contents, this.createdAt});

  // Firestore map + docId -> Faq
  factory Faq.fromMap(Map<String, dynamic> map, String id) {
    final ts = map['createdAt'] as Timestamp?;
    return Faq(
      id: id,
      title: (map['title'] ?? '') as String,
      contents: (map['contents'] ?? '') as String,
      createdAt: ts?.toDate(),
    );
  }

  // (선택) DocumentSnapshot => Faq
  factory Faq.fromDoc(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return Faq.fromMap(map, doc.id);
  }

  // Faq -> Firebase Map (insert/update용)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'contents': contents,
      // createdAt은 보통 생성 시에만 serverTimestamp로 넣음
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // factory Faq.fromFirestore(DocumentSnapshot doc) {
  //   final data = doc.data() as Map<String, dynamic>;

  //   final ts = data['createdAt'] as Timestamp?;
  //   return Faq(
  //     no: (data['no'] ?? 0) as int,
  //     title: (data['title'] ?? '') as String,
  //     contents: (data['contents'] ?? '') as String,
  //     createdAt: ts?.toDate(),
  //   );
  // }

  /// Faq -> Firestore Map (insert/update용)
  // Map<String, dynamic> toMap() {
  //   return {
  //     'no': no,
  //     'title': title,
  //     'contents': contents,
  //     // createdAt은 보통 "등록할 때만" 서버시간으로 찍는 걸 권장해서
  //     // 여기서는 안 넣거나, 필요하면 넣어도 됨.
  //   };
  // }
}
