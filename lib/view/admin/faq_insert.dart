import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/util/color.dart';
import 'package:seatup_app/vm/faq_provider.dart';

class FaqInsert extends ConsumerWidget {
  FaqInsert({super.key});

  final TextEditingController titleController =
      TextEditingController();
  final TextEditingController contentsController =
      TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saving = ref.watch(faqInsertSavingProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Center(
          child: Column(
            children: [
              contentsTitle(),
              TextField(
                controller: titleController,

                decoration: InputDecoration(
                  labelText: '제목',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.sublack,
                      width: 1,
                    ),
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
                  labelText: '내용을 입력하세요',
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
                    : () => insertAction(context, ref),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(4),
                  ),
                  backgroundColor: AppColors.suyellow,
                  foregroundColor: AppColors.textColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 5, 10, 5),
                  child: SizedBox(
                    width: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.add_outlined),
                        Text(' 등록 하기'),
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

  // ========================== functions ======================================
  Future<void> insertAction(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final saving = ref.read(faqInsertSavingProvider);
    if (saving) return;

    final title = titleController.text.trim();
    final contents = contentsController.text.trim();

    if (title.isEmpty || contents.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('빈칸 없이 작성 해주세요.')));
      return;
    }
    // ref.read(faqInsertSavingProvider.notifier).state = true; // 유무에 작동 되는지 확인하기

    try {
      await ref
          .read(faqActionProvider.notifier)
          .addFaq(title: title, contents: contents);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('등록 실패 : $e')));
    } finally {
      ref.read(faqInsertSavingProvider.notifier).state = false;
    }
  }
} // class
