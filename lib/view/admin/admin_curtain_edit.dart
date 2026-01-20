import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/curtain.dart';
import 'package:seatup_app/vm/admin_edit_notifier.dart';

class AdminCurtainEdit extends ConsumerStatefulWidget {
  final Curtain initialData;

  const AdminCurtainEdit({super.key, required this.initialData});

  @override
  ConsumerState<AdminCurtainEdit> createState() => _AdminCurtainEditConsumerState();
}

class _AdminCurtainEditConsumerState extends ConsumerState<AdminCurtainEdit> {
  final _formKey = GlobalKey<FormState>();

  // ---------- Dropdown (단일) ----------
  String typeValue = '뮤지컬';
  final List<String> typeItems = const ['뮤지컬', '콘서트', '연극', '클래식'];

  // ---------- Multi Select (복수) ----------
  final List<String> gradeItems = const ['VIP', 'R', 'S', 'A', 'B'];
  final List<String> areaItems = const ['A구역', 'B구역', 'C구역', 'D구역', 'E구역', 'F구역'];

  List<String> selectedGrades = [];
  List<String> selectedAreas = [];

  // ---------- TextField ----------
  late final TextEditingController titleCtrl;
  late final TextEditingController placeCtrl;
  late final TextEditingController curtainDateCtrl;
  late final TextEditingController curtainTimeCtrl;

  // ✅ 추가
  late final TextEditingController curtainDescCtrl;
  late final TextEditingController curtainPicCtrl;

  @override
  void initState() {
    super.initState();

    final d = widget.initialData;

    typeValue = d.curtain_type.toString();
    if (!typeItems.contains(typeValue)) typeValue = typeItems.first;

    titleCtrl = TextEditingController(text: d.curtain_title.toString());
    placeCtrl = TextEditingController(text: d.curtain_place.toString());
    curtainDateCtrl = TextEditingController(text: d.curtain_date.toString());
    curtainTimeCtrl = TextEditingController(text: d.curtain_time?.toString() ?? '');

    curtainDescCtrl = TextEditingController(text: d.curtain_desc.toString());
    curtainPicCtrl = TextEditingController(text: d.curtain_pic.toString());

    // ✅ 기존 값이 단일로 들어있다면(예: "VIP") → 리스트로 변환해서 초기 체크
    //   (DB에 "VIP,R" 같이 저장돼있으면 split(',')로 바꾸면 됨)
    if (d.curtain_grade != null) {
      final g = d.curtain_grade.toString();
      if (gradeItems.contains(g)) selectedGrades = [g];
    }
    if (d.curtain_area != null) {
      final a = d.curtain_area.toString();
      if (areaItems.contains(a)) selectedAreas = [a];
    }
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    placeCtrl.dispose();
    curtainDateCtrl.dispose();
    curtainTimeCtrl.dispose();
    curtainDescCtrl.dispose();
    curtainPicCtrl.dispose();
    super.dispose();
  }

  void _submitUpdate() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // ✅ 여기서 서버로 보낼 값 만들기 (예시)
    final payload = {
      "type": typeValue,
      "title": titleCtrl.text.trim(),
      "place": placeCtrl.text.trim(),
      "curtain_date": curtainDateCtrl.text.trim(),
      "curtain_time": curtainTimeCtrl.text.trim(),
      "curtain_desc": curtainDescCtrl.text.trim(),
      "curtain_pic": curtainPicCtrl.text.trim(),
      "grades": selectedGrades, // ✅ 복수 선택
      "areas": selectedAreas,   // ✅ 복수 선택
    };

    // print(payload);
    // TODO: update API 호출
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '제품 정보 수정',
          style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.w900),
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
                        // 안내 문구
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F6FF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE0E6FF)),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.edit_note_outlined, size: 20, color: Color(0xFF2F57C9)),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '기존 정보를 수정한 후 저장하세요.',
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

                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // 1줄: type + title
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: _dashDropdown(
                                        label: 'type',
                                        value: typeValue,
                                        items: typeItems,
                                        onChanged: (v) => setState(() => typeValue = v),
                                      ),
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

                                // 2줄: place
                                Row(
                                  children: [
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

                                // ✅ 3줄: grade(복수) + area(복수)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _multiSelectBox(
                                        label: 'grade (복수 선택)',
                                        items: gradeItems,
                                        selected: selectedGrades,
                                        onToggle: (v) {
                                          setState(() {
                                            if (selectedGrades.contains(v)) {
                                              selectedGrades.remove(v);
                                            } else {
                                              selectedGrades.add(v);
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _multiSelectBox(
                                        label: 'area (복수 선택)',
                                        items: areaItems,
                                        selected: selectedAreas,
                                        onToggle: (v) {
                                          setState(() {
                                            if (selectedAreas.contains(v)) {
                                              selectedAreas.remove(v);
                                            } else {
                                              selectedAreas.add(v);
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // 4줄: curtain_date + show_time
                                Row(
                                  children: [
                                    Expanded(
                                      child: _dashPickerField(
                                        label: 'curtain_date',
                                        controller: curtainDateCtrl,
                                        hint: '예: 2026-02-11',
                                        icon: Icons.calendar_today_outlined,
                                        onTapIcon: _pickDate,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _dashPickerField(
                                        label: 'show_time',
                                        controller: curtainTimeCtrl,
                                        hint: '예: 14:00',
                                        icon: Icons.schedule_outlined,
                                        onTapIcon: _pickTime,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // ✅ 추가: curtain_desc
                                _dashTextArea(
                                  label: 'curtain_desc',
                                  controller: curtainDescCtrl,
                                  hint: '설명 (여러 줄 입력 가능)',
                                ),
                                const SizedBox(height: 12),

                                // ✅ 추가: 이미지 링크
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

                        Row(
                          children: [
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF2F57C9),
                                side: const BorderSide(color: Color(0xFFCFD8FF)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text('취소', style: TextStyle(fontWeight: FontWeight.w800)),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4D74D6),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              ),
                              onPressed: _submitUpdate,
                              child: const Text('저장', style: TextStyle(fontWeight: FontWeight.w900)),
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

  // ------------------ 공통 UI ------------------
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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

  Widget _dashTextArea({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dashLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          minLines: 3,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF4F6FF),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF2F57C9)),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }

  // ✅ 복수 선택 박스 (선택한 값은 Chip으로 보이고, 아래에서 체크박스 선택)
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

  // ------------------ Date/Time pick ------------------
  Future<void> _pickDate() async {
    final edit = ref.read(adminEditNotifierProvider.notifier);
    final value = await edit.pickDate(context);
    if (value.isNotEmpty) setState(() => curtainDateCtrl.text = value);
  }

  Future<void> _pickTime() async {
    final edit = ref.read(adminEditNotifierProvider.notifier);
    final value = await edit.pickTime(context);
    if (value.isNotEmpty) setState(() => curtainTimeCtrl.text = value);
  }
}
