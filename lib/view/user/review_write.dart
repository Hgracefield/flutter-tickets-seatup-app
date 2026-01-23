import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seatup_app/util/color.dart';
import 'package:seatup_app/util/text_form.dart';
import 'package:seatup_app/vm/curtain_reviews_notifier.dart';
import 'package:seatup_app/vm/image_handler.dart';

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
          title: TextForm.suAppText(text: "관람 후기 작성"),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      Text(' *', style: TextStyle(color: Colors.red)),
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
                        borderSide: BorderSide(color: AppColors.suyellow),
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
                        borderSide: BorderSide(color: AppColors.suyellow),
                      ),
                    ),
                    maxLength: 5000,
                    maxLines: 3,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    children: [
                      _buildImagePicker(ref),
                      // _buildImagePicker(ref),
                      // _buildImagePicker(ref),
                    ],
                  ),
                ),
          
                _text('• 업로드한 이미지 저작권 및 초상권 관련 책임은 게시자 본인에게 있습니다.'),
                _text('• 사진은 최대 1장까지 등록 가능합니다.'),
                // _text('• 사진은 최대 3장까지 등록 가능합니다.'),
                _text('• 10MB 이하의 jpg, png, gif, pdf 이미지가 업로드 가능합니다.'),
                _text('• 상품과 무관한 내용이거나 음란 및 불법적인 내용은 통보 없이 삭제될 수 있습니다.'),
          
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.sublack,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(10),
                            ),
                            minimumSize: Size(10, 50),
                          ),
                          child: Text("취소"),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (titleController.text.isNotEmpty &&
                                contentController.text.isNotEmpty) {
                              await reviewActions.addReview(
                                titleController.text,
                                contentController.text,
                              );
                              titleController.clear();
                              contentController.clear();
                               ref.read(imageNotifierProvider.notifier).clearImage();
                              if (!context.mounted) return;
                              _snackBar(context, "후기가 등록되었습니다.", Colors.blue);
                            } else {
                              if (!context.mounted) return;
                              _snackBar(context, "제목과 내용을 모두 입력해 주세요.", Colors.red);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.suyellow,
                            foregroundColor: AppColors.textColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(10),
                            ),
                            minimumSize: Size(10, 50),
                          ),
                          child: Text("등록하기"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  } // build

  // --- Widgets ---
  Widget _text(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildImagePicker(WidgetRef ref) {
    final ImageNotifier = ref.read(imageNotifierProvider.notifier);
    final image = ref.watch(imageNotifierProvider).imageFile;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: image == null
            ? Center(
                child: IconButton(
                  onPressed: () =>
                      ImageNotifier.getImageFromGallery(ImageSource.gallery),
                  icon: Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.grey.shade400,
                  ),
                ),
              )
            : Image.file(File(image.path)),
      ),
    );
  }

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
