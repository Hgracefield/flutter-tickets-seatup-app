import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seatup_app/util/color.dart';
import 'package:seatup_app/model/faq.dart';
import 'package:seatup_app/vm/faq_provider.dart';

class FaqList extends ConsumerWidget {
  const FaqList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final faqsAsync = ref.watch(faqListProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
        child: Column(
          children: [
            contentsTitle(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [insertBtn(context), SizedBox(width: 8), editBtn(context, ref)],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: boardListHeader(),
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
  Widget editBtn(BuildContext context, WidgetRef ref) {
    final selectedDocId = ref.watch(faqselectedProvider);
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
    // final canEdit = selectedDocId != null;

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
  Widget updateBtn(BuildContext context, WidgetRef ref) {
    final selectedDocId = ref.watch(faqselectedProvider);
    final canEdit = selectedDocId != null;
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
      //  style: ElevatedButton.styleFrom(
      //           shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(4),
      //           ),
      //           backgroundColor: canEdit ? const Color(0xFF4D74D6) : const Color(0xFFE5E7EB),
      //           foregroundColor: canEdit ? Colors.white : const Color(0xFF9CA3AF),
      //         ),
      icon: const Icon(Icons.mode_edit),
      label: const Text('수정'),
    );
  }

  // 입력 버튼
  Widget insertBtn(BuildContext context) {
    return SizedBox(
      width: 110,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, '/faq_insert');
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          backgroundColor: const Color(0xFFF8DE7D), // seatupYellow
          foregroundColor: const Color(0xFF39393F), // seatupDark
          elevation: 0,
        ),
        icon: const Icon(Icons.add_outlined),
        label: const Text('등록', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  // 글 리스트 (documentsnapshot => faq 로 변경)
  Widget buildItemWidget(BuildContext context, WidgetRef ref, Faq faq) {
    final selectedDocId = ref.watch(faqselectedProvider);
    final expandedDocId = ref.watch(faqExpandedProvider);
    final isExpanded = expandedDocId == faq.id;

    final dateText = (faq.createdAt == null)
        ? ''
        : DateFormat('yy.MM.dd').format(faq.createdAt!);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.black)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey(faq.id),
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) {
            ref.read(faqExpandedProvider.notifier).state = expanded ? faq.id : null;
          },
          title: Row(
            children: [
              SizedBox(
                width: 50,
                child: Checkbox(
                  value: selectedDocId == faq.id,
                  onChanged: (checked) {
                    ref.read(faqselectedProvider.notifier).state = checked == true
                        ? faq.id
                        : null;

                    ref.read(faqExpandedProvider.notifier).state = checked == true
                        ? faq.id
                        : null;
                  },
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        'Q. ',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        faq.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
                      title: Text('삭제할까요?'),
                      content: Text('삭제하면 되돌릴 수 없어요.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('삭제'),
                        ),
                      ],
                    ),
                  );

                  if (ok != true) return;

                  try {
                    await ref.read(faqActionProvider.notifier).deleteFaq(faq.id);
                    // 삭제한 항목이 선택/확장 상태였으면 정리
                    if (ref.read(faqselectedProvider) == faq.id) {
                      ref.read(faqselectedProvider.notifier).state = null;
                    }

                    if (ref.read(faqExpandedProvider) == faq.id) {
                      ref.read(faqExpandedProvider.notifier).state = null;
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('삭제 실패 : $e')));
                  }
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'A.',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          faq.contents,
                          style: const TextStyle(
                            fontSize: 14,
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
    );
  }
} // class
