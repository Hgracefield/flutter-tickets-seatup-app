import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seatup_app/vm/faq_provider.dart';

class FaqInsert extends ConsumerStatefulWidget {
  // <<<<<<<<<<<<<
  const FaqInsert({super.key});

  @override
  ConsumerState<FaqInsert> createState() =>
      _FaqInsertState(); //<<<<<
}

class _FaqInsertState extends ConsumerState<FaqInsert> {
  //<<<<<
  // property
  TextEditingController noController =
      TextEditingController();
  TextEditingController titleController =
      TextEditingController();
  TextEditingController contentsController =
      TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    titleController.text.trim();
    contentsController.text.trim();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Center(
          child: Column(
            children: [
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
  Future<void> insertAction() async {
    if (_saving) return;

    final title = titleController.text.trim();
    final contents = contentsController.text.trim();

    if (title.isEmpty || contents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('빈칸 없이 작성 해주세요.')),
      );
      return;
    }
    setState(() => _saving = true);

    try {
      await ref
          .read(faqActionProvider.notifier)
          .addFaq(title: title, contents: contents);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('등록 실패 : $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
} // class
