import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/util/color.dart';
import 'package:seatup_app/util/side_menu.dart';
import 'package:seatup_app/view/admin/admin_side_bar.dart';
import 'package:seatup_app/vm/faq_provider.dart';

class FaqInsert extends ConsumerWidget {
  FaqInsert({super.key});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentsController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saving = ref.watch(faqInsertSavingProvider);

    return Scaffold(
      backgroundColor: AppColors.adminBackgroundColor,
      body: SafeArea(
        child: Row(
          children: [
            AdminSideBar(selectedMenu: SideMenu.transaction, onMenuSelected: (_) {}),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    contentsTitle(),

                    const SizedBox(height: 20),

                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: '제목',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.sublack, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.textColor, width: 2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    adminInsertTextfield(
                      controller: contentsController,
                      labelText: '내용을 입력하세요.',
                      maxLines: 20,
                    ),

                    const SizedBox(height: 30),

                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: saving ? null : () => insertAction(context, ref),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.suyellow,
                          foregroundColor: AppColors.textColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: SizedBox(
                          width: 90,
                          height: 48,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add_outlined, size: 22),
                              SizedBox(width: 4),
                              Text('등록 하기'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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

  // textfield WG
  Widget adminInsertTextfield({
    required TextEditingController controller,
    required String labelText,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      enabled: enabled,
      cursorColor: AppColors.textColor,

      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF1F2937),
      ),

      decoration: InputDecoration(
        labelText: labelText,

        labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),

        floatingLabelStyle: TextStyle(
          color: AppColors.textColor,
          fontWeight: FontWeight.w700,
        ),

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textColor, width: 2),
        ),

        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.sublack.withOpacity(0.2)),
        ),
      ),
    );
  }

  // ========================== functions ======================================
  Future<void> insertAction(BuildContext context, WidgetRef ref) async {
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
      await ref.read(faqActionProvider.notifier).addFaq(title: title, contents: contents);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('등록 실패 : $e')));
    } finally {
      ref.read(faqInsertSavingProvider.notifier).state = false;
    }
  }
} // class
