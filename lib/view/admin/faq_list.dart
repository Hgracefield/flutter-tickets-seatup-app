import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:seatup_app/model/faq.dart';

// 컬러
// const seatupYellow = Color.fromRGBO(248, 222, 125, 1); // rgb(248,222,125)
// const seatupDark   = Color.fromRGBO(57, 57, 63, 1);    // rgb(57,57,63)
// const seatupYellow = Color(0xFFF8DE7D);
// const seatupDark   = Color(0xFF39393F);

class FaqList extends StatefulWidget {
  const FaqList({super.key});

  @override
  State<FaqList> createState() => _FaqListState();
}

class _FaqListState extends State<FaqList> {
  // property

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FAQs'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/faq_insert');
            },
            icon: Icon(Icons.add_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 7,
              ),
              child: boardListHeader(),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('FAQs')
                    .orderBy('no', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final documents = snapshot.data!.docs;
                  return ListView(
                    children: documents
                        .map((e) => buildItemWidget(e))
                        .toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  } // build

  //============================= widgets===================================================
  // 리스트 헤더
  Widget boardListHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: Color.fromRGBO(248, 222, 125, 1),
        border: Border(
          bottom: BorderSide(color: Colors.black12),
        ),
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          color: Color.fromRGBO(57, 57, 63, 1),
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        child: Row(
          children: const [
            SizedBox(
              width: 100,
              child: Text(
                '글번호',

                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Text(
                'FAQ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              width: 70,
              child: Text(
                '등록일',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 글 리스트
  Widget buildItemWidget(DocumentSnapshot doc) {
    final faq = Faq.fromFirestore(doc);
    const seatupDark = Color(0xFF39393F);
    final dateText = (faq.createdAt == null)
        ? ''
        : DateFormat('yy.MM.dd').format(faq.createdAt!);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/faq_update',
          arguments: doc.id,
        );
      },
      child: Slidable(
        endActionPane: ActionPane(
          motion: BehindMotion(),

          children: [
            SlidableAction(
              backgroundColor: Colors.redAccent,
              icon: Icons.delete_forever,
              label: '삭제',
              onPressed: (context) async {
                FirebaseFirestore.instance
                    .collection('FAQs')
                    .doc(doc.id)
                    .delete();
              },
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.black),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 6,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text(
                    '${faq.no}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: seatupDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        faq.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: seatupDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Text(
                      //   faq.contents,
                      //   maxLines: 1,
                      //   overflow: TextOverflow.ellipsis,
                      //   style: const TextStyle(
                      //     color: Color(0xFF7A7A86),
                      //     fontSize: 12,
                      //     fontWeight: FontWeight.w500,
                      //   ),
                      // ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: Text(
                    dateText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF7A7A86),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} // class
