import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/util/color.dart';
import 'package:seatup_app/vm/faq_provider.dart';

class FaqUpdate extends ConsumerStatefulWidget {
  FaqUpdate({super.key});

  @override
  ConsumerState<FaqUpdate> createState() => _FaqUpdateState();
}

class _FaqUpdateState extends ConsumerState<FaqUpdate> {
  // property
  TextEditingController titleController = TextEditingController();
  TextEditingController contentsController = TextEditingController();
  TextEditingController createdController = TextEditingController();
  String? _docId;
  @override
  void initState() {
    super.initState();

    titleController = TextEditingController();
    contentsController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initOnce();
    });
  }

  void _initOnce() {
    if (_docId != null) return;

    _docId = ModalRoute.of(context)?.settings.arguments as String?;

    if (_docId == null) {
      ref.read(faqUpdateLoadingProvider.notifier).state = false;
      return;
    }

    _loadDoc(_docId!);
  }

  Future<void> _loadDoc(String docId) async {
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
      // 에러
    } finally {
      ref.read(faqUpdateLoadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(faqUpdateLoadingProvider);
    final saving = ref.watch(faqUpdateSavingProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      contentsTitle(),
                      SizedBox(height: 16),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: '제목',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.textColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: contentsController,
                        decoration: InputDecoration(
                          labelText: '내용',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.textColor,
                              width: 2,
                            ),
                          ),
                        ),

                        maxLines: 12,
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: saving
                            ? null
                            : () => updateAction(),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadiusGeometry.circular(4),
                          ),
                          backgroundColor: AppColors.suyellow,
                          foregroundColor: AppColors.textColor,
                        ),
                        child: SizedBox(
                          width: 80,
                          child: Row(
                            children: [
                              Icon(Icons.add_rounded),
                              Text('수정하기'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  } // build

  // ==================================== wdigets ==================================================================
  // 관리자 contents title
  Widget contentsTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 18, 24, 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'FAQ 수정하기',
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

  // ==========================functions ===============================
  Future<void> updateAction() async {
    if (_docId == null) return;
    if (ref.read(faqUpdateSavingProvider)) return;

    final title = titleController.text.trim();
    final contents = contentsController.text.trim();

    if (title.isEmpty || contents.isEmpty) return;

    ref.read(faqUpdateSavingProvider.notifier).state = true;

    try {
      await ref
          .read(faqActionProvider.notifier)
          .updateFaq(id: _docId!, title: title, contents: contents);
      Navigator.pop(context, true);
    } finally {
      ref.read(faqUpdateSavingProvider.notifier).state = false;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentsController.dispose();
    super.dispose();
  }
} // class
