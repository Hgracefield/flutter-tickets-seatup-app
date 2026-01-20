import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/vm/faq_provider.dart';

class FaqUpdate extends ConsumerStatefulWidget {
  const FaqUpdate({super.key});

  @override
  ConsumerState<FaqUpdate> createState() =>
      _FaqUpdateState();
}

class _FaqUpdateState extends ConsumerState<FaqUpdate> {
  // property
  TextEditingController titleController =
      TextEditingController();
  TextEditingController contentsController =
      TextEditingController();
  TextEditingController createdController =
      TextEditingController();

  String? docId;
  bool _loaded = false;
  bool _saving = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((
      _,
    ) async {
      docId =
          ModalRoute.of(context)?.settings.arguments
              as String?;
      if (docId == null) {
        setState(() => _loaded = true);
        return;
      }
      await _loadDoc();
    });
  }

  // 데이터 불러오기
  Future<void> _loadDoc() async {
    if (docId == null) return;

    try {
      final snap = await FirebaseFirestore.instance
          .collection('FAQs')
          .doc(docId)
          .get();

      final data = snap.data();
      if (data != null) {
        titleController.text = data['title'] ?? '';
        contentsController.text = data['contents'] ?? '';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('불러오기 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loaded = true);
      }
    }
  }

  // ==========================functions ===============================
  Future<void> updateAction() async {
    if (docId == null) return;
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
          .watch(faqActionProvider.notifier)
          .updateFaq(
            id: docId!,
            title: title,
            contents: contents,
          );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('수정 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !_loaded
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                0,
              ),
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(height: 16),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: '제목',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: contentsController,
                        decoration: InputDecoration(
                          labelText: '내용',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 12,
                      ),
                      ElevatedButton(
                        onPressed: _saving
                            ? null
                            : updateAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('수정하기'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  } // build

  // ================================== widgets ==============================
  // 수정 텍스트 필드
} // class
