import 'package:cloud_firestore/cloud_firestore.dart';

class Faq {
  int no;
  String title;
  String contents;
  DateTime? createdAt;
  Faq({
    required this.no,
    required this.title,
    required this.contents,
    this.createdAt,
  });

  /// Firestore -> Faq
  factory Faq.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final ts = data['createdAt'] as Timestamp?;
    return Faq(
      no: (data['no'] ?? 0) as int,
      title: (data['title'] ?? '') as String,
      contents: (data['contents'] ?? '') as String,
      createdAt: ts?.toDate(),
    );
  }

  /// Faq -> Firestore Map (insert/update용)
  Map<String, dynamic> toMap() {
    return {
      'no': no,
      'title': title,
      'contents': contents,
      // createdAt은 보통 "등록할 때만" 서버시간으로 찍는 걸 권장해서
      // 여기서는 안 넣거나, 필요하면 넣어도 됨.
    };
  }
}
