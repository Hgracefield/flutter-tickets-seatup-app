import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/vm/area_notifier.dart';
import 'package:seatup_app/vm/curtain_dashboard_notifier.dart';
import 'package:seatup_app/vm/curtain_manager_notifier.dart';
import 'package:seatup_app/vm/curtain_notifier.dart';
import 'package:seatup_app/vm/grade_notifier.dart';
import 'package:seatup_app/vm/place_notifier.dart';
import 'package:seatup_app/vm/title_notifier.dart';
import 'package:seatup_app/vm/type_provider.dart';
import 'package:seatup_app/util/message.dart';

/// ✅ 등록 버튼을 누르면 나오는 "등록 페이지"
/// - type / grade / area : Dropdown
/// - title / location / place / show_date / show_time / show_cast : TextField
/// - 대시보드 톤(블루 + 카드 + 둥근테두리) 맞춤
///
/// 사용법:
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (_) => const AdminCurtainInsert()),
/// );
class AdminCurtainInsert extends ConsumerStatefulWidget {
  const AdminCurtainInsert({super.key});

  @override
  ConsumerState<AdminCurtainInsert> createState() => _AdminCurtainInsertState();
}

class _AdminCurtainInsertState extends ConsumerState<AdminCurtainInsert> {
  final _formKey = GlobalKey<FormState>();

  // // ---------- Dropdown 기본값 ----------
  // String typeValue = '뮤지컬';
  // String gradeValue = 'VIP';
  // String areaValue = 'A구역';

  // // ---------- Dropdown 아이템 ----------
  // final List<String> typeItems = const ['뮤지컬', '콘서트', '연극', '클래식'];
  // final List<String> gradeItems = const ['VIP', 'R', 'S', 'A', 'B'];
  // final List<String> areaItems = const [
  //   'A구역',
  //   'B구역',
  //   'C구역',
  //   'D구역',
  //   'E구역',
  //   'F구역',
  // ];

  // ---------- TextField ----------
  final showDateCtrl = TextEditingController();
  final showTimeCtrl = TextEditingController();
  final TextEditingController curtainDescCtrl = TextEditingController();
  final TextEditingController curtainPicCtrl = TextEditingController();

  String typeValue = '뮤지컬';
  String gradeValue = 'VIP';
  String areaValue = 'A구역';

  Message message = Message(); 

  bool isLoadingComplete = false; 

  @override
  void initState() {
    super.initState();

    Future.microtask((){

    ref.read(curtainManagerNotifier.notifier).reset();

    
      // await initData();
    },);
  }

  @override
  void dispose() {
    // locationCtrl.dispose();
    showDateCtrl.dispose();
    showTimeCtrl.dispose();
    // castCtrl.dispose();
    curtainDescCtrl.dispose();
    curtainPicCtrl.dispose();

    super.dispose();
  }

  // Future initData() async{
    
  //   ref.read(curtainManagerNotifier.notifier).reset();
  //   isLoadingComplete = true;

  // }

  // (선택) 날짜/시간 선택 도우미: 텍스트필드 입력도 가능 + 아이콘 누르면 picker
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
      initialDate: now,
    );
    if (picked != null) {
      final y = picked.year.toString();
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      setState(() => showDateCtrl.text = '$y-$m-$d');
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 14, minute: 0),
    );
    if (t != null) {
      final hh = t.hour.toString().padLeft(2, '0');
      final mm = t.minute.toString().padLeft(2, '0');
      setState(() => showTimeCtrl.text = '$hh:$mm');
    }
  }

  Future _submit() async {
  
    if(showDateCtrl.text.trim().isEmpty ||
    showTimeCtrl.text.trim().isEmpty ||
    curtainPicCtrl.text.trim().isEmpty ||
    curtainDescCtrl.text.trim().isEmpty
     )
     {
      message.errorSnackBar(context, '빈 공란이 있어요');
     }
     else
     {
      final payload = <String, dynamic> {
        'curtain_id': 0,
        'curtain_date':showDateCtrl.text.trim(),
        'curtain_time':showTimeCtrl.text.trim(),
        'curtain_desc':curtainDescCtrl.text.trim(),
        'curtain_pic':curtainPicCtrl.text.trim(),
        'curtain_place':ref.watch(curtainManagerNotifier).selectedPlaceIndex,
        'curtain_type':ref.watch(curtainManagerNotifier).selectedTypeIndex,
        'curtain_title': ref.watch(curtainManagerNotifier).selectedTitleIndex,
        'curtain_grade':ref.watch(curtainManagerNotifier).selectedGradeMask,
        'curtain_area':ref.watch(curtainManagerNotifier).selectedAreaMask,
      };

      final result = await ref.read(curtainNotifierProvider.notifier).insertCurtain(payload);

      if(!mounted) return;

      if(result == 'OK')
      {
        Navigator.pop(context);
        await ref.read(adminCurtainNotifer.notifier).refresh();
        message.successSnackBar(context, '등록에 성공 했어요.');
      }
      else
      {
        message.successSnackBar(context, '등록에 실패 했어요.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    // ref.watch(curtainManagerNotifier);
    //  if (!isLoadingComplete) {
    //   return const Scaffold(
    //     body: Center(child: CircularProgressIndicator()),
    //   );
    // }
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860, maxHeight: 800),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCFD8FF)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 안내 문구 (대시보드 톤)
                        _buildInformation(),
                        const SizedBox(height: 14),
                        // 폼 영역 (스크롤 가능)
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // 1줄: type + title
                                Row(
                                  children: [
                                    Expanded(child: _buildTypeDropDown('type')),
                                    const SizedBox(width: 12),

                                    Expanded(child: _buildTtitleDropDown('title')),
                                    // Expanded(
                                    //   child: _dashTextField(
                                    //     label: 'title',
                                    //     controller: titleCtrl,
                                    //     hint: '공연 제목',
                                    //     requiredField: true,
                                    //   ),
                                    // ),
                                  ],
                                ),
          
                                const SizedBox(height: 12),
          
                                // 2줄: location + place
                                Row(
                                  children: [
                                    // Expanded(
                                    //   child: _dashTextField(
                                    //     label: 'location',
                                    //     controller: locationCtrl,
                                    //     hint: '지역 (예: 서울)',
                                    //     requiredField: true,
                                    //   ),
                                    // ),
                                    Expanded(child: _buildPlaceDropDown('place')),
                                    // const SizedBox(width: 12),
                                    // Expanded(
                                    //   child: _dashTextField(
                                    //     label: 'place',
                                    //     controller: placeCtrl,
                                    //     hint: '공연장 (예: 예술의 전당)',
                                    //     requiredField: true,
                                    //   ),
                                    // ),
                                  ],
                                ),
          
                                const SizedBox(height: 12),
          
                                // // 3줄: grade + area
                                Row(
                                  children: [
                                    Expanded(child: _buildGradeCheckList('grade')),
                                    SizedBox(width: 12,),
                                    // Expanded(child: _buildGradeCheckList('grade')),
                                    Expanded(child: _buildAreaCheckList('area'))
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Row(
                                //   children: [
                                //     // _dashLabel('area'),
                                //     // Expanded(child: _buildAreaCheckList()),
                                //   ],
                                // ),
                                const SizedBox(height: 12),
          
                                // 4줄: show_date + show_time (입력 가능 + picker 아이콘)
                                Row(
                                  children: [
                                    Expanded(
                                      child: _dashPickerField(
                                        label: 'show_date',
                                        controller: showDateCtrl,
                                        hint: '예: 2026-02-11',
                                        icon: Icons.calendar_today_outlined,
                                        onTapIcon: _pickDate,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _dashPickerField(
                                        label: 'show_time',
                                        controller: showTimeCtrl,
                                        hint: '예: 14:00',
                                        icon: Icons.schedule_outlined,
                                        onTapIcon: _pickTime,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
          
                                _dashTextArea(
                                  label: 'curtain_desc',
                                  controller: curtainDescCtrl,
                                  hint: '설명 (여러 줄 입력 가능)',
                                ),
                                const SizedBox(height: 12),
          
                                _dashTextField(
                                  label: 'curtain_pic (image url)',
                                  controller: curtainPicCtrl,
                                  hint: 'https://...',
                                ),
                              ],
                            ),
                          ),
                        ),
          
                        const SizedBox(height: 12),
          
                        // 하단 버튼
                        Row(
                          children: [
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF2F57C9),
                                side: const BorderSide(color: Color(0xFFCFD8FF)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                '취소',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4D74D6),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                              ),
                              onPressed: _submit,
                              child: const Text(
                                '등록',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===================== 대시보드 스타일 공통 위젯 =====================
  Widget _dashLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w800,
      color: Color(0xFF2F57C9),
    ),
  );

  Widget _dashTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool requiredField = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _dashLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF4F6FF),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E6FF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF4D74D6), width: 2),
            ),
          ),
          validator: (v) {
            if (!requiredField) return null;
            if (v == null || v.trim().isEmpty) return '$label 는 필수입니다';
            return null;
          },
        ),
      ],
    );
  }

  Widget _dashPickerField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required VoidCallback onTapIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dashLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF4F6FF),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            suffixIcon: IconButton(
              onPressed: onTapIcon,
              icon: Icon(icon, size: 18, color: const Color(0xFF2F57C9)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E6FF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF4D74D6), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        '제품 정보 등록',
        style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.w900),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF1E3A8A)),
    );
  }

  // Widget _dashDropdown({
  //   required String label,
  //   required String value,
  //   required List<String> items,
  //   required ValueChanged<String> onChanged,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       _dashLabel(label),
  //       const SizedBox(height: 6),
  //       Container(
  //         height: 48,
  //         padding: const EdgeInsets.symmetric(horizontal: 12),
  //         decoration: BoxDecoration(
  //           color: const Color(0xFFF4F6FF),
  //           borderRadius: BorderRadius.circular(10),
  //           border: Border.all(color: const Color(0xFFE0E6FF)),
  //         ),
  //         child: DropdownButtonHideUnderline(
  //           child: DropdownButton<String>(
  //             value: value,
  //             isExpanded: true,
  //             icon: const Icon(
  //               Icons.keyboard_arrow_down,
  //               color: Color(0xFF2F57C9),
  //             ),
  //             items: items
  //                 .map((e) => DropdownMenuItem(value: e, child: Text(e)))
  //                 .toList(),
  //             onChanged: (v) {
  //               if (v != null) onChanged(v);
  //             },
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildTypeDropDown(String label) {
    final typeAsync = ref.watch(typeNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dashLabel(label),
        const SizedBox(height: 6),
        typeAsync.when(
          data: (types) {
            if (types.isEmpty) return const SizedBox();

            // 선택된 값(그대로 저장/사용)
            final selected = ref
                .watch(curtainManagerNotifier)
                .selectedTypeIndex;
            // selectGradeIndex 타입이 int? 라고 가정 (gradeId 또는 gradeBit)

            final int? value =
                (selected != null && types.any((g) => g.type_seq == selected))
                ? selected
                : null;

            // 최초 기본값 세팅(원하면 제거 가능)
            if (value == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref
                    .read(curtainManagerNotifier.notifier)
                    .setType(types.first.type_seq!);
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
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: value,
                  hint: const Text('좌석 등급 선택'),
                  items: types
                      .map(
                        (type) => DropdownMenuItem<int>(
                          value: type.type_seq, // 여기만 id로 바꾸고 싶으면 g.id
                          child: Text(type.type_name),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    ref.read(curtainManagerNotifier.notifier).setType(v);
                  },
                ),
              ),
            );
          },
          error: (_, __) => const SizedBox(),
          loading: () => const SizedBox(),
        ),
      ],
    );
  }

  Widget _buildTtitleDropDown(String label) {
    final titleAsync = ref.watch(titleNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dashLabel(label),
        const SizedBox(height: 6),
        titleAsync.when(
          data: (titles) {
            if (titles.isEmpty) return const SizedBox();

            // 선택된 값(그대로 저장/사용)
            final selected = ref
                .watch(curtainManagerNotifier)
                .selectedTitleIndex;
            // selectGradeIndex 타입이 int? 라고 가정 (gradeId 또는 gradeBit)

            final int? value =
                (selected != null && titles.any((t) => t.title_seq == selected))
                ? selected
                : null;

            // 최초 기본값 세팅(원하면 제거 가능)
            if (value == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref
                    .read(curtainManagerNotifier.notifier)
                    .setType(titles.first.title_seq!);
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
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: value,
                  hint: const Text('제목 선택'),
                  items: titles
                      .map(
                        (title) => DropdownMenuItem<int>(
                          value: title.title_seq, // 여기만 id로 바꾸고 싶으면 g.id
                          child: Text(title.title_contents),
                        ),
                      )
                      .toList(),
                  onChanged: (t) {
                    if (t == null) return;
                    ref.read(curtainManagerNotifier.notifier).setTitle(t);
                  },
                ),
              ),
            );
          },
          error: (_, __) => const SizedBox(),
          loading: () => const SizedBox(),
        ),
      ],
    );
  }

  Widget _buildPlaceDropDown(String label) {
    final placeAsync = ref.watch(placeNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dashLabel(label),
        const SizedBox(height: 6),
        placeAsync.when(
          data: (places) {
            if (places.isEmpty) return const SizedBox();

            // 선택된 값(그대로 저장/사용)
            final selected = ref
                .watch(curtainManagerNotifier)
                .selectedPlaceIndex;
            // selectGradeIndex 타입이 int? 라고 가정 (gradeId 또는 gradeBit)

            final int? value =
                (selected != null && places.any((place) => place.place_seq == selected))
                ? selected
                : null;

            // 최초 기본값 세팅(원하면 제거 가능)
            if (value == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref
                    .read(curtainManagerNotifier.notifier)
                    .setPlace(places.first.place_seq!);
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
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: value,
                  hint: const Text('좌석 등급 선택'),
                  items: places
                      .map(
                        (place) => DropdownMenuItem<int>(
                          value: place.place_seq, // 여기만 id로 바꾸고 싶으면 g.id
                          child: Text(place.place_name),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    ref.read(curtainManagerNotifier.notifier).setPlace(v);
                  },
                ),
              ),
            );
          },
          error: (_, __) => const SizedBox(),
          loading: () => const SizedBox(),
        ),
      ],
    );
  }

  Widget _buildGradeCheckList(String label) {
  final gradeAsync = ref.watch(gradeNotifierProvider);
  final mask = ref.watch(curtainManagerNotifier).selectedGradeMask ?? 0;

  return gradeAsync.when(
    loading: () => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dashLabel(label),
        const SizedBox(height: 6),
        const SizedBox(height: 48),
      ],
    ),
    error: (_, __) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dashLabel(label),
        const SizedBox(height: 6),
        const Text('불러오기 실패'),
      ],
    ),
    data: (grades) {
      final items = grades.map((g) => g.grade_name).toList();

      final selected = grades
          .where((g) => (mask & g.bit) != 0)
          .map((g) => g.grade_name)
          .toList();

      return _multiSelectBox(
        label: label,
        items: items,
        selected: selected,
        onToggle: (name) {
          final grade = grades.firstWhere((g) => g.grade_name == name);
          final isChecked = (mask & grade.bit) != 0;

          ref
              .read(curtainManagerNotifier.notifier)
              .toggleGrade(grade.bit, !isChecked);
        },
      );
    },
  );
}

  Widget _buildAreaCheckList(String label) {
  final areaAsync = ref.watch(areaNotifierProvider);
  final mask = ref.watch(curtainManagerNotifier).selectedAreaMask ?? 0;

  return areaAsync.when(
    loading: () => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dashLabel(label),
        const SizedBox(height: 6),
        const SizedBox(height: 48),
      ],
    ),
    error: (_, __) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dashLabel(label),
        const SizedBox(height: 6),
        const Text('불러오기 실패'),
      ],
    ),
    data: (areas) {
      final items = areas.map((area) => area.area_number).toList();

      final selected = areas
          .where((a) => (mask & a.bit) != 0)
          .map((a) => a.area_number)
          .toList();

      return _multiSelectBox(
        label: label,
        items: items,
        selected: selected,
        onToggle: (name) {
          final area = areas.firstWhere((a) => a.area_number == name);
          final isChecked = (mask & area.bit) != 0;

          ref
              .read(curtainManagerNotifier.notifier)
              .toggleArea(area.bit, !isChecked);
        },
      );
    },
  );
}

Widget _multiSelectBox({
    required String label,
    required List<String> items,
    required List<String> selected,
    required ValueChanged<String> onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dashLabel(label),
        const SizedBox(height: 6),

        // 선택된 값 Chip 표시
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F6FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE0E6FF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selected.isEmpty
                    ? [const Text('선택 없음', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)))]
                    : selected
                        .map(
                          (v) => Chip(
                            label: Text(v, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => onToggle(v),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),

              // 체크박스 리스트
              ...items.map((v) {
                final checked = selected.contains(v);
                return CheckboxListTile(
                  dense: true,
                  value: checked,
                  onChanged: (_) => onToggle(v),
                  title: Text(v, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                );
              }),
            ],
          ),
        ),
      ],
    );
  }


  // Widget _buildAreaCheckList(String label) {
  //   final areaAsync = ref.watch(areaNotifierProvider);
  //   final mask = ref.watch(curtainManagerNotifier).selectedAreaMask;

  //   return areaAsync.when(
  //     data: (areas) {
  //       return Wrap(
  //         spacing: 12,
  //         runSpacing: 8,
  //         children: areas.map((area) {
  //           final checked = (mask! & area.bit) != 0;
  //           return Row(
  //             mainAxisSize: MainAxisSize.min, // 핵심
  //             children: [
  //               Checkbox(
  //                 value: checked,
  //                 onChanged: (v) {
  //                   if (v == null) return;
  //                   ref
  //                       .read(curtainManagerNotifier.notifier)
  //                       .toggleGrade(area.bit, v);
  //                 },
  //               ),
  //               Text(area.area_number),
  //             ],
  //           );
  //         }).toList(),
  //       );
  //     },
  //     loading: () => const SizedBox(),
  //     error: (_, __) => const SizedBox(),
  //   );
  // } // _buildGradeDropDown

  Widget _buildInformation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E6FF)),
      ),
      child: Row(
        children: const [
          Icon(
            Icons.confirmation_number_outlined,
            size: 20,
            color: Color(0xFF2F57C9),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '티켓 리셀 상품 정보를 입력하고 등록하세요.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  } // _buildInformation

  Widget _dashTextArea({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _dashLabel(label),
        const SizedBox(height: 6),
        SizedBox(
          height: 140, // 원하는 높이로 조절
          child: TextField(
            controller: controller,
            minLines: null,
            maxLines: null,
            expands: true,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: const Color(0xFFF4F6FF),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE0E6FF)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF4D74D6),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  } // _dashTextArea
} // class
