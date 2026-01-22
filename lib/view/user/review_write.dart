import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/util/btn_style.dart';
import 'package:seatup_app/vm/curtain_reviews_notifier.dart';

class ReviewWrite extends ConsumerStatefulWidget {
  ReviewWrite({super.key});

  @override
  ConsumerState<ReviewWrite> createState() => _ReviewWriteState();
}

class _ReviewWriteState extends ConsumerState<ReviewWrite> {
  late final TextEditingController titleController;
  late final TextEditingController contentController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    contentController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    contentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reviewActions = ref.read(reviewActionProvider.notifier);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "관람 후기 작성",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  children: [
                    Text(
                      '문의 내용',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('*', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: '제목을 입력해 주세요.',
                    hintStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextField(
                  controller: contentController,
                  decoration: InputDecoration(
                    hintText: '문의하실 내용을 입력해 주세요.',
                    hintStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey, width: 2),
                    ),
                  ),
                  maxLength: 5000,
                  maxLines: 3,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    // child: ElevatedButton(
                    //   onPressed: () => Navigator.pop(context),
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.grey.shade300,
                    //     foregroundColor: Colors.black,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadiusGeometry.circular(10),
                    //     ),
                    //     minimumSize: Size(10, 50),
                    //   ),
                    //   child: Text("취소"),
                    // ),
                    child: BtnStyle.primary(
                      text: '취소',
                      onPressed: () => Navigator.pop(context)
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    // child: ElevatedButton(
                    //   onPressed: () async {
                    //     if (titleController.text.isNotEmpty &&
                    //         contentController.text.isNotEmpty) {
                    //       await reviewActions.addReview(
                    //         titleController.text,
                    //         contentController.text,
                    //       );
                    //       titleController.clear();
                    //       contentController.clear();
                    //       if (!context.mounted) return;
                    //       _snackBar(context, "후기가 등록되었습니다.", Colors.blue);
                    //     } else {
                    //       if (!context.mounted) return;
                    //       _snackBar(context, "제목과 내용을 모두 입력해 주세요.", Colors.red);
                    //     }
                    //   },
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.black,
                    //     foregroundColor: Colors.white,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadiusGeometry.circular(10),
                    //     ),
                    //     minimumSize: Size(10, 50),
                    //   ),
                    //   child: Text("등록하기"),
                    // ),
                    child: BtnStyle.primary(
                      text: '등록하기',
                      onPressed: () async {
                        if (titleController.text.isNotEmpty &&
                            contentController.text.isNotEmpty) {
                          await reviewActions.addReview(
                            titleController.text,
                            contentController.text,
                          );
                          titleController.clear();
                          contentController.clear();
                          if (!context.mounted) return;
                          _snackBar(context, "후기가 등록되었습니다.", Colors.blue);
                        } else {
                          if (!context.mounted) return;
                          _snackBar(context, "제목과 내용을 모두 입력해 주세요.", Colors.red);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  } // build

  // --- Functions ---
  void _snackBar(BuildContext context, String str, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(str),
        duration: Duration(seconds: 1),
        backgroundColor: color,
      ),
    );
  }
} // class
