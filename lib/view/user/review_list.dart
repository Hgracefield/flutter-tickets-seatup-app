import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/curtain_review.dart';
import 'package:seatup_app/util/color.dart';
import 'package:seatup_app/util/text_form.dart';
import 'package:seatup_app/vm/curtain_reviews_notifier.dart';

class ReviewList extends ConsumerStatefulWidget {
  const ReviewList({super.key});

  @override
  ConsumerState<ReviewList> createState() => _ReviewListState();
}

class _ReviewListState extends ConsumerState<ReviewList> {
  @override
  Widget build(BuildContext context) {
    final reviewAsync = ref.watch(reviewListProvider);
    final reviewActions = ref.read(reviewActionProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: TextForm.suAppText(text: "관람 후기"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: reviewAsync.when(
                data: (reviewList) {
                  return reviewList.isEmpty
                      ? Center(child: Text("작성된 리뷰가 없습니다."))
                      : ListView.separated(
                          itemCount: reviewList.length,
                          itemBuilder: (context, index) {
                            CurtainReview review = reviewList[index];
                            return ListTile(
                              title: Text(review.title),
                              subtitle: Text(review.content),
                              trailing: IconButton(
                                onPressed: () async {
                                  await reviewActions.deleteReview(review.id);
                                  if (!context.mounted) return;
                                  _snackBar(
                                    context,
                                    "후기가 삭제 되었습니다.",
                                    Colors.blue,
                                  );
                                },
                                icon: Icon(
                                  Icons.delete,
                                  color: AppColors.warnColor,
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) => Divider(),
                        );
                },
                error: (error, stackTrace) =>
                    Center(child: Text('오류 : $error')),
                loading: () => Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // build
  void _snackBar(BuildContext context, String str, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(str),
        duration: Duration(seconds: 2),
        backgroundColor: color,
      ),
    );
  }
} // class
