import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:seatup_app/main.dart';
import 'package:seatup_app/util/color.dart';
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
  // 체크박스
  bool faqCheck = false;
  // 체크 박스 상태 변수
  // 선택된 faq문서 id (없으면 null)
  String? selectedDocId;
  bool canEdit = false;
  // contents 확장
  String? expandedDocId;
  // 초기 설정
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
        child: Column(
          children: [
            contentsTitle(),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [editBtn()]),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
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
                    return Center(child: CircularProgressIndicator());
                  }
                  final documents = snapshot.data!.docs;
                  return ListView(
                    children: documents.map((e) => buildItemWidget(e)).toList(),
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
  // 관리자 contents title
  Widget contentsTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 18, 24, 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            '게시판',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
        ],
      ),
    );
  }

  // 수정 버튼
  Widget editBtn() {
    final canEdit = selectedDocId != null;

    return SizedBox(
      width: 100,
      child: ElevatedButton.icon(
        onPressed: canEdit
            ? () {
                Navigator.pushNamed(context, '/faq_update', arguments: selectedDocId);
              }
            : null,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(4)),
          backgroundColor: canEdit ? const Color(0xFF4D74D6) : const Color(0xFFE5E7EB),
          foregroundColor: canEdit ? Colors.white : const Color(0xFF9CA3AF),
        ),

        icon: const Icon(Icons.mode_edit),
        label: const Text('수정', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  // 리스트 헤더
  Widget boardListHeader() {
    final canEdit = selectedDocId != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: Color.fromRGBO(248, 222, 125, 1),
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          color: Color.fromRGBO(57, 57, 63, 1),
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'FAQ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '등록일',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 수정 버튼 체크박스가 클릭되어야 활성화 됨.
  Widget updateBtn() {
    return TextButton.icon(
      onPressed: canEdit
          ? () {
              Navigator.pushNamed(
                context,
                '/faq_update', // 수정 페이지 라우트로
                arguments: selectedDocId,
              );
            }
          : null,

      icon: const Icon(Icons.mode_edit),
      label: const Text('수정'),
    );
  }

  // 글 리스트
  Widget buildItemWidget(DocumentSnapshot doc) {
    final faq = Faq.fromFirestore(doc);
    bool isSelected = selectedDocId == doc.id;
    const seatupDark = Color(0xFF39393F);
    final dateText = (faq.createdAt == null)
        ? ''
        : DateFormat('yy.MM.dd').format(faq.createdAt!);
    final isExpanded = expandedDocId == doc.id;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.black)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey(doc.id),
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              expandedDocId = expanded ? doc.id : null;
            });
          },
          title: Row(
            children: [
              SizedBox(
                width: 50,
                child: Checkbox(
                  value: selectedDocId == doc.id,
                  onChanged: (value) {
                    selectedDocId = (value == true) ? doc.id : null;
                    setState(() {});
                  },
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        faq.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: seatupDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  dateText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF7A7A86),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              IconButton(
                tooltip: '삭제',
                icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                onPressed: () async {
                  // (선택) 삭제 확인 다이얼로그
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('삭제할까요?'),
                      content: const Text('삭제하면 되돌릴 수 없어요.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('삭제'),
                        ),
                      ],
                    ),
                  );

                  if (ok != true) return;

                  await FirebaseFirestore.instance
                      .collection('FAQs')
                      .doc(doc.id)
                      .delete();

                  // 삭제한 항목이 선택/확장 상태였으면 정리
                  if (selectedDocId == doc.id) selectedDocId = null;
                  if (expandedDocId == doc.id) expandedDocId = null;

                  setState(() {});
                },
              ),
            ],
          ),
          // 클릭시 내용 보기
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 221, 221, 221),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      faq.contents,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 0, 0, 0),
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} // class
