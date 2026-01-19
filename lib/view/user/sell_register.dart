import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/area.dart';
import 'package:seatup_app/model/curtain.dart';
import 'package:seatup_app/model/grade.dart';
import 'package:seatup_app/vm/area_notifier.dart';
import 'package:seatup_app/vm/curtain_list_provider.dart';
import 'package:seatup_app/vm/curtain_notifier.dart';
import 'package:seatup_app/vm/grade_notifier.dart';
import 'package:seatup_app/vm/sell_register_notifier.dart';
import 'package:seatup_app/vm/title_notifier.dart';

class SellRegister extends ConsumerStatefulWidget {
  const SellRegister({super.key});

  @override
  ConsumerState<SellRegister> createState() => _SellRegisterState();
}

class _SellRegisterState extends ConsumerState<SellRegister> {
  // ---------- TextField ----------
  final titleCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final placeCtrl = TextEditingController();
  final showDateCtrl = TextEditingController();
  final showTimeCtrl = TextEditingController();
  final castCtrl = TextEditingController();

  List<Grade> gradeList = [];
  List<Area> areaList = [];
   List<Curtain> curtainList = [];
     int gradeIndex = 0;
  int areaIndex = 0;
  @override
  void initState() {
    super.initState();
    // final c = curtainListProvider
    initData();
  }

  @override
  Widget build(BuildContext context) {
    final curtainAsync = ref.watch(curtainNotifierProvider);
    final selectState = ref.watch(sellRegisterNotifier);

    return Scaffold(
      appBar: AppBar(title: Text('판매 등록'), centerTitle: true),
      body: Center(
        child: Column(
          children: [
            curtainAsync.when(
              data: (curtainList) {
                if (curtainList.isNotEmpty && selectState.selectCurtainIndex! < 0) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final first = curtainList.first;
                    ref.read(sellRegisterNotifier.notifier).setCurtain(first.curtain_id!);
                  });
                }
                return curtainList.isEmpty
                    ? Center()
                    : _selectCurtainDropdownById(
                        label: '공연 제목',
                        value:
                            (selectState.selectCurtainIndex! >= 0 &&
                                curtainList.any(
                                  (c) => c.curtain_id == selectState.selectCurtainIndex,
                                ))
                            ? selectState.selectCurtainIndex
                            : null,
                        items: curtainList,
                        onChanged: (id) {
                          if (id == null) return;
                          ref.read(sellRegisterNotifier.notifier).setCurtain(id);

                          final c = curtainList.firstWhere(
                            (x) => x.curtain_id == id,
                          );
                        },
                      );
              },
              error: (e, st) => Text('curtain error: $e'),
              loading: () => const SizedBox(
                height: 48,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),

            Column(
              children: [
                selectState.selectCurtainIndex! >= 0
                ?
                _buildReadOnlyLabel('공연 날짜', selectState.selectCurtainIndex.toString())//curtainList. curtainList.any((element) => element.curtain_id == selectState.selectCurtainIndex).toString())
                : Center()
              ],
            ),
          ],
        ),
      ),
    );
  } // build

  // === Widgets ===

  Widget _selectCurtainDropdownById({
    required String label,
    required int? value, // 선택된 curtain_id
    required List<Curtain> items,
    required ValueChanged<int?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F6FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE0E6FF)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF2F57C9),
              ),
              items: items
                  .map(
                    (c) => DropdownMenuItem<int>(
                      value: c.curtain_id,
                      child: Text(c.curtain_title),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyLabel(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(title),
        const SizedBox(height: 6),
        TextField(
          controller: TextEditingController(text: content),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFF4F6FF),
          ),
          readOnly: true,
        ),
      ],
    );
  }

  Widget _Label(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w800,
      color: Color(0xFF2F57C9),
    ),
  );


  // === Functions ===

  Future initData() async {
    final gradeNotifier = ref.read(gradeNotifierProvider.notifier);
    gradeList = await gradeNotifier.fetchGrade();

    final areaNotifier = ref.read(areaNotifierProvider.notifier);
    areaList = await areaNotifier.fetchArea();
  }
}
