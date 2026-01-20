import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seatup_app/util/color.dart';
import 'package:seatup_app/model/faq.dart';
import 'package:seatup_app/vm/faq_provider.dart';

class UserFaq extends ConsumerWidget {
  const UserFaq({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final faqsAsync = ref.watch(faqListProvider);

    return Scaffold(
      appBar: AppBar(title: Text('FAQ')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                '티켓 구매 자주 묻는 질문',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: faqsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('불러오기 실패: $e')),
                data: (faqs) {
                  return ListView(
                    primary: false,
                    // controller: ScrollController(),
                    children: faqs
                        .map((faq) => buildItemWidget(context, ref, faq))
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

  // 글 리스트 (documentsnapshot => faq 로 변경)
  Widget buildItemWidget(BuildContext context, WidgetRef ref, Faq faq) {
    // 펼치기
    final expandedDocId = ref.watch(faqExpandedProvider);
    final isExpanded = expandedDocId == faq.id;
    // 일자 가져오기
    final dateText = (faq.createdAt == null)
        ? ''
        : DateFormat('yy.MM.dd').format(faq.createdAt!);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            // bottom: BorderSide(color: AppColors.sublack)
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: PageStorageKey(faq.id),
            initiallyExpanded: isExpanded,
            onExpansionChanged: (expanded) {
              ref.read(faqExpandedProvider.notifier).state == expandedDocId
                  ? faq.id
                  : null;
            },
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Q. ',
                            style: TextStyle(
                              color: AppColors.sublack,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              faq.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                  child: Text(
                    dateText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 141, 141, 152),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                      color: AppColors.suyellow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'A. ',
                            style: TextStyle(
                              color: AppColors.sublack,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            faq.contents,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} // class
