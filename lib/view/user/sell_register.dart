import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/curtain.dart';
import 'package:seatup_app/model/post.dart';
import 'package:seatup_app/util/message.dart';
import 'package:seatup_app/vm/area_notifier.dart';
import 'package:seatup_app/vm/curtain_notifier.dart';
import 'package:seatup_app/vm/grade_notifier.dart';
import 'package:seatup_app/vm/post_notifier.dart';
import 'package:seatup_app/vm/sell_register_notifier.dart';

class SellRegister extends ConsumerStatefulWidget {
  const SellRegister({super.key});

  @override
  ConsumerState<SellRegister> createState() => _SellRegisterState();
}

class _SellRegisterState extends ConsumerState<SellRegister> {
  // ---------- TextField ----------
  final amountController = TextEditingController();
  final priceController = TextEditingController();
  final descController = TextEditingController();

  Message mmessage = Message();
 
  Curtain? _curtain;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    amountController.dispose();
    priceController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curtainAsync = ref.watch(curtainNotifierProvider);
    final selectState = ref.watch(sellRegisterNotifier);

    return Scaffold(
      appBar: AppBar(title: Text('판매 등록'), centerTitle: true),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                curtainAsync.when(
                  data: (curtainList) {
                    if (curtainList.isNotEmpty &&
                        selectState.selectCurtainIndex! < 0) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        final first = curtainList.first;
                        ref
                            .read(sellRegisterNotifier.notifier)
                            .setCurtain(first.curtain_id!);
                      });
                    }
                    return curtainList.isEmpty
                        ? SizedBox()
                        : _selectCurtainDropdownById(
                            label: '공연 제목',
                            value:
                                (selectState.selectCurtainIndex! >= 0 &&
                                    curtainList.any(
                                      (c) =>
                                          c.curtain_id ==
                                          selectState.selectCurtainIndex,
                                    ))
                                ? selectState.selectCurtainIndex
                                : null,
                            items: curtainList,
                            onChanged: (id) {
                              if (id == null) return;
                              ref
                                  .read(sellRegisterNotifier.notifier)
                                  .setCurtain(id);
                              _curtain = curtainList.firstWhere(
                                (element) =>
                                    element.curtain_id ==
                                    selectState.selectCurtainIndex,
                              );
                              // final c = curtainList.firstWhere(
                              //   (x) => x.curtain_id == id,
                              // );
                            },
                          );
                  },
                  error: (e, st) => Text('curtain error: $e'),
                  loading: () => const SizedBox(
                    height: 48,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                _curtain != null 
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10,),
                    _buildReadOnlyLabel(
                      '공연 날짜',
                      _curtain == null ? '' : _curtain!.curtain_date,
                    ),
                    SizedBox(height: 10,),
                    _buildReadOnlyLabel(
                      '위치',
                      _curtain == null ? '' : _curtain!.curtain_place,
                    ),
                    SizedBox(height: 10,),
                    _Label('좌석 등급'),
                    _buildGradeDropDown(),
                    SizedBox(height: 10,),
                    _Label('구역'),
                    _buildAreaDropDown(),
                    SizedBox(height: 10,),
                    _buildTextFiled('판매 매수', amountController, TextInputType.number),
                    SizedBox(height: 10,),
                    _buildTextFiled('판매 금액', priceController, TextInputType.number),
                    SizedBox(height: 10,),
                    _buildTextFiled('설명', descController, TextInputType.text),
                    SizedBox(height: 10,),
                    ElevatedButton(onPressed: () async {
                      Post post = Post(
                        post_user_id: 1, 
                        post_curtain_id: _curtain!.curtain_id! , 
                        post_area: ref.watch(sellRegisterNotifier).selectAreaIndex!,
                        post_grade: ref.watch(sellRegisterNotifier).selectGradeIndex!,
                        post_quantity: int.parse(amountController.text.trim()), 
                        post_price: int.parse(priceController.text.trim()),
                        post_desc: descController.text.trim(),
                        );
                        final result = await ref.read(postNotifierProvider.notifier).insertPost(post);
                        // print(result);
            
                        if (!mounted) return;
                        if(result == "OK")
                        {
                          ref.read(sellRegisterNotifier.notifier).reset();
                          Navigator.pop(context);
                          mmessage.successSnackBar(context, '등록에 성공 했답니다');
                        }
                        else
                        {
                            mmessage.errorSnackBar(context, '등록에 실패 했답니다');
                        }
                    }, child: Text('등록'))
                  ],
                )
                : SizedBox()
              ],
            ),
          ),
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

  Widget _buildGradeDropDown() {
    final gradeAsync = ref.watch(gradeNotifierProvider);
    return gradeAsync.when(
      data: (data) {
        if (_curtain == null) return const SizedBox();

        final grades = data
            .where((g) => (_curtain!.curtain_grade & g.bit) != 0)
            .toList();

        final selectedGradeBit = ref
            .watch(sellRegisterNotifier)
            .selectGradeIndex; 

        final int? value =
            (selectedGradeBit != null &&
                grades.any((g) => g.bit == selectedGradeBit))
            ? selectedGradeBit
            : null;

        if (grades.isNotEmpty && value == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(sellRegisterNotifier.notifier).setGrade(grades.first.bit);
          });
        }
        return Container(
           height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F6FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE0E6FF)),
          ),
          child: DropdownButton<int>(
            value: value,
            hint: const Text('좌석 등급 선택'),
            items: grades
                .map(
                  (g) => DropdownMenuItem<int>(
                    value: g.bit,
                    child: Text(g.grade_name),
                  ),
                )
                .toList(),
            onChanged: (bit) {
              if (bit == null) return;
              ref.read(sellRegisterNotifier.notifier).setGrade(bit);
            },
          ),
        );
      },
      error: (e, st) => const SizedBox(),
      loading: () => const SizedBox(),
    );
  } // _buildGradeDropDown

  Widget _buildAreaDropDown() {
    final areaAsync = ref.watch(areaNotifierProvider);
    return areaAsync.when(
      data: (data) {
        if (_curtain == null) return const SizedBox();

        final areas = data
            .where((a) => (_curtain!.curtain_area & a.bit) != 0)
            .toList();

        final selectedAreaBit = ref
            .watch(sellRegisterNotifier)
            .selectAreaIndex; 

        final int? value =
            (selectedAreaBit != null &&
                areas.any((a) => a.bit == selectedAreaBit))
            ? selectedAreaBit
            : null;

        if (areas.isNotEmpty && value == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(sellRegisterNotifier.notifier).setArea(areas.first.bit);
          });
        }
        return Container(
           height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F6FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE0E6FF)),
          ),
          child: DropdownButton<int>(
            value: value,
            hint: const Text('구역 선택'),
            items: areas
                .map(
                  (a) => DropdownMenuItem<int>(
                    value: a.bit,
                    child: Text(a.area_number),
                  ),
                )
                .toList(),
            onChanged: (bit) {
              if (bit == null) return;
              ref.read(sellRegisterNotifier.notifier).setArea(bit);
            },
          ),
        );
      },
      error: (e, st) => const SizedBox(),
      loading: () => const SizedBox(),
    );
  } // _buildAreaDropDown

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

  Widget _buildTextFiled(String title, TextEditingController controller, TextInputType type ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(title),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFF4F6FF),
          ),
          keyboardType: type,
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

} // class
