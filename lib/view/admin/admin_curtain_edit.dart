import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:seatup_app/model/curtain.dart';
import 'package:seatup_app/vm/admin_edit_notifier.dart';
import 'package:seatup_app/vm/type_provider.dart';

// ✅ 선택된 type 값을 Riverpod으로 관리
final selectedTypeProvider = StateProvider.autoDispose<String?>((ref) => null);

class AdminCurtainEdit extends ConsumerStatefulWidget {
  final Curtain initialData;

  const AdminCurtainEdit({super.key, required this.initialData});

  @override
  ConsumerState<AdminCurtainEdit> createState() => _AdminCurtainEditConsumerState();
}

class _AdminCurtainEditConsumerState extends ConsumerState<AdminCurtainEdit> {
  final _formKey = GlobalKey<FormState>();

  // ---------- Multi Select (복수) ----------
  final List<String> gradeItems = const ['VIP', 'R', 'S', 'A'];
  final List<String> areaItems = const ['A구역', 'B구역', 'C구역', 'D구역'];

  List<String> selectedGrades = [];
  List<String> selectedAreas = [];

  // ---------- TextField ----------
  late final TextEditingController titleCtrl;
  late final TextEditingController placeCtrl;
  late final TextEditingController curtainDateCtrl;
  late final TextEditingController curtainTimeCtrl;

  // 추가
  late final TextEditingController curtainDescCtrl;
  late final TextEditingController curtainPicCtrl;

  @override
  void initState() {
    super.initState();

    final d = widget.initialData;

    titleCtrl = TextEditingController(text: d.curtain_title.toString());
    placeCtrl = TextEditingController(text: d.curtain_place.toString());
    curtainDateCtrl = TextEditingController(text: d.curtain_date.toString());
    curtainTimeCtrl = TextEditingController(text: d.curtain_time.toString());

    curtainDescCtrl = TextEditingController(text: d.curtain_desc.toString());
    curtainPicCtrl = TextEditingController(text: d.curtain_pic.toString());

    // ✅ type 초기값은 provider에 넣어둠 (setState 필요없음)
    ref.read(selectedTypeProvider.notifier).state = d.curtain_type?.toString();

    // ✅ grade/area 초기 체크
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

    final typeValue = ref.read(selectedTypeProvider);

    final payload = {
      "type": typeValue ?? "",
      "title": titleCtrl.text.trim(),
      "place": placeCtrl.text.trim(),
      "curtain_date": curtainDateCtrl.text.trim(),
      "curtain_time": curtainTimeCtrl.text.trim(),
      "curtain_desc": curtainDescCtrl.text.trim(),
      "curtain_pic": curtainPicCtrl.text.trim(),
      "grades": selectedGrades,
      "areas": selectedAreas,
    };

    // TODO: update API 호출
    // print(payload);
  }

  @override
  Widget build(BuildContext context) {
    // ✅ types는 watch + when으로 처리
    final typesAsync = ref.watch(typeNotifierProvider);
    final selectedType = ref.watch(selectedTypeProvider);

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
                                      child: typesAsync.when(
                                        loading: () => _loadingDropdown(label: 'type'),
                                        error: (e, _) => _errorDropdown(label: 'type', message: '$e'),
                                        data: (types) {
                                          final typeItems = types.map((e) => e.type_name).toList();

                                          if (typeItems.isEmpty) {
                                            return _errorDropdown(label: 'type', message: 'type 목록이 비어있음');
                                          }

                                          // ✅ 선택값이 items에 없으면 첫번째로 보정 + provider에 반영
                                          final safeValue = typeItems.contains(selectedType)
                                              ? selectedType!
                                              : typeItems.first;

                                          if (selectedType != safeValue) {
                                            // build 중 state 변경은 다음 프레임으로 미룸
                                            WidgetsBinding.instance.addPostFrameCallback((_) {
                                              ref.read(selectedTypeProvider.notifier).state = safeValue;
                                            });
                                          }

                                          return _dashDropdown(
                                            label: 'type',
                                            value: safeValue,
                                            items: typeItems,
                                            onChanged: (v) {
                                              ref.read(selectedTypeProvider.notifier).state = v;
                                            },
                                          );
                                        },
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

  Widget _loadingDropdown({required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dashLabel(label),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF4F6FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE0E6FF)),
          ),
          child: const Center(
            child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        ),
      ],
    );
  }

  Widget _errorDropdown({required String label, required String message}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dashLabel(label),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFCA5A5)),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            message,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFB91C1C)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

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
    final safeValue = items.contains(value) ? value : items.first;

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
              value: safeValue,
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
