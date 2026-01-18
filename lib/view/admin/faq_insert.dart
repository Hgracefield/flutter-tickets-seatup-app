import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart'
    hide Card;
import 'package:intl/intl.dart';

class FaqInsert extends StatefulWidget {
  const FaqInsert({super.key});

  @override
  State<FaqInsert> createState() => _FaqInsertState();
}

class _FaqInsertState extends State<FaqInsert> {
  // property
  TextEditingController noController =
      TextEditingController();
  TextEditingController titleController =
      TextEditingController();
  TextEditingController contentsController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('faq insert page')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Center(
          child: Column(
            children: [
              TextField(
                controller: noController,
                decoration: InputDecoration(
                  labelText: 'No.',
                ),
              ),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: '제목',
                ),
              ),
              TextField(
                controller: contentsController,
                decoration: InputDecoration(
                  labelText: '내용을 입력하세요',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  insertAction();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 80,
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end,
                      children: [
                        Text('등록 하기'),
                        Icon(Icons.add_outlined),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  } // build
  // ============================ widgets =====================================

  Widget buildItemWidget(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final ts = data['createdAt'] as Timestamp?;
    final createdAtText = (ts == null)
        ? ''
        : DateFormat('yy.MM.dd').format(ts.toDate());

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/faq_update',
          arguments: doc.id,

          // main에 route 등록해야함.
          // MaterialPageRoute(
          //     builder: (_) => FaqUpdate(docId: doc.id),
          //   ),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text('${data['no']}'),
              ),
              Expanded(child: Text('${data['title']}')),
              SizedBox(
                width: 110,
                child: Text(
                  createdAtText,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========================== functions ======================================
  void insertAction() async {
    final int no =
        int.tryParse(noController.text.trim()) ?? 0;
    FirebaseFirestore.instance.collection('FAQs').add({
      'no': no,
      'title': titleController.text.trim(),
      'contents': contentsController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (!mounted) return;
    Navigator.pop(context);
    // _showDialog();
  }
} // class
