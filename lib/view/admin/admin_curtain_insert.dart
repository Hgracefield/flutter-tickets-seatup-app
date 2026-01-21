import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/vm/area_notifier.dart';
import 'package:seatup_app/vm/curtain_manager_notifier.dart';
import 'package:seatup_app/vm/grade_notifier.dart';
import 'package:seatup_app/vm/type_provider.dart';

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

  // ---------- Dropdown 기본값 ----------
  String typeValue = '뮤지컬';
  String gradeValue = 'VIP';
  String areaValue = 'A구역';

  // ---------- Dropdown 아이템 ----------
  final List<String> typeItems = const ['뮤지컬', '콘서트', '연극', '클래식'];
  final List<String> gradeItems = const ['VIP', 'R', 'S', 'A', 'B'];
  final List<String> areaItems = const [
    'A구역',
    'B구역',
    'C구역',
    'D구역',
    'E구역',
    'F구역',
  ];

  // ---------- TextField ----------
  final titleCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final placeCtrl = TextEditingController();
  final showDateCtrl = TextEditingController();
  final showTimeCtrl = TextEditingController();
  final castCtrl = TextEditingController();

  @override
  void dispose() {
    titleCtrl.dispose();
    locationCtrl.dispose();
    placeCtrl.dispose();
    showDateCtrl.dispose();
    showTimeCtrl.dispose();
    castCtrl.dispose();
    super.dispose();
  }

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

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final payload = <String, dynamic>{
      'type': typeValue,
      'grade': gradeValue,
      'area': areaValue,
      'title': titleCtrl.text.trim(),
      'location': locationCtrl.text.trim(),
      'place': placeCtrl.text.trim(),
      'show_date': showDateCtrl.text.trim(),
      'show_time': showTimeCtrl.text.trim(),
      'show_cast': castCtrl.text.trim(),
    };

    // ✅ 여기서 API 호출로 등록해도 되고,
    // ✅ 지금은 payload를 이전 화면으로 반환
    Navigator.pop(context, payload);
  }

  @override
  Widget build(BuildContext context) {

    final typeAsync = ref.watch(typeNotifierProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '제품 정보 등록',
          style: TextStyle(
            color: Color(0xFF1E3A8A),
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1E3A8A)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
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
                        ),

                        const SizedBox(height: 14),

                        // 폼 영역 (스크롤 가능)
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // 1줄: type + title
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: _buildTypeDropDown(),
                                      // _dashDropdown(
                                      //   label: 'type',
                                      //   value: typeValue,
                                      //   items: typeItems,
                                      //   onChanged: (v) =>
                                      //       setState(() => typeValue = v),
                                      // ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 2,
                                      child: _dashTextField(
                                        label: 'title',
                                        controller: titleCtrl,
                                        hint: '공연 제목',
                                        requiredField: true,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // 2줄: location + place
                                Row(
                                  children: [
                                    Expanded(
                                      child: _dashTextField(
                                        label: 'location',
                                        controller: locationCtrl,
                                        hint: '지역 (예: 서울)',
                                        requiredField: true,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _dashTextField(
                                        label: 'place',
                                        controller: placeCtrl,
                                        hint: '공연장 (예: 예술의 전당)',
                                        requiredField: true,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // 3줄: grade + area
                                Row(
                                  children: [
                                    _dashLabel('grade'),
                                    Expanded(
                                      child: _buildGradeCheckList(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _dashLabel('area'),
                                    Expanded(
                                      child: _buildAreaCheckList(),
                                    ),
                                  ],
                                ),

                               
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
                                side: const BorderSide(
                                  color: Color(0xFFCFD8FF),
                                ),
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

  Widget _dashDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dashLabel(label),
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
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF2F57C9),
              ),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeDropDown()
  {
    final typeAsync = ref.watch(typeNotifierProvider);

  return typeAsync.when(
    data: (types) {
      if (types.isEmpty) return const SizedBox();

      // 선택된 값(그대로 저장/사용)
      final selected = ref.watch(curtainManagerNotifier).selectedTypeIndex; 
      // selectGradeIndex 타입이 int? 라고 가정 (gradeId 또는 gradeBit)

      final int? value =
          (selected != null && types.any((g) => g.type_seq == selected))
              ? selected
              : null;

      // 최초 기본값 세팅(원하면 제거 가능)
      if (value == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(curtainManagerNotifier.notifier).setType(types.first.type_seq!);
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
  );
  }

  Widget _buildGradeCheckList() {
    final gradeAsync = ref.watch(gradeNotifierProvider);
    final mask = ref.watch(curtainManagerNotifier).selectedGradeMask;

    return gradeAsync.when(
      data: (grades) {
        return Wrap(
          spacing: 12,
          runSpacing: 8,
          children: grades.map((g) {
            final checked = (mask! & g.bit) != 0;
            return Row(
              mainAxisSize: MainAxisSize.min, // 핵심
              children: [
                Checkbox(
                  value: checked,
                  onChanged: (v) {
                    if (v == null) return;
                    ref
                        .read(curtainManagerNotifier.notifier)
                        .toggleGrade(g.bit, v);
                  },
                ),
                Text(g.grade_name),
              ],
            );
          }).toList(),
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  } // _buildGradeDropDown

  Widget _buildAreaCheckList() {
    final areaAsync = ref.watch(areaNotifierProvider);
    final mask = ref.watch(curtainManagerNotifier).selectedAreaMask;

    return areaAsync.when(
      data: (areas) {
        return Wrap(
          spacing: 12,
          runSpacing: 8,
          children: areas.map((area) {
            final checked = (mask! & area.bit) != 0;
            return Row(
              mainAxisSize: MainAxisSize.min, // 핵심
              children: [
                Checkbox(
                  value: checked,
                  onChanged: (v) {
                    if (v == null) return;
                    ref
                        .read(curtainManagerNotifier.notifier)
                        .toggleGrade(area.bit, v);
                  },
                ),
                Text(area.area_number),
              ],
            );
          }).toList(),
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  } // _buildGradeDropDown
} // class
