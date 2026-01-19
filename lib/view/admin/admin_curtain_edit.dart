import 'package:flutter/material.dart';

/// ✅ 수정 페이지
/// - 등록 페이지와 동일한 UI/스타일
/// - 초기값(initialData)로 폼 채움
/// - 저장(수정) 누르면 수정된 Map을 pop으로 반환
///
/// 사용법(대시보드에서):
/// final updated = await Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => AdminCurtainEdit(initialData: rows[index]),
///   ),
/// );
/// if(updated != null){
///   setState(() => rows[index] = updated);
/// }
class AdminCurtainEdit extends StatefulWidget {
  final Map<String, dynamic> initialData;

  const AdminCurtainEdit({
    super.key,
    required this.initialData,
  });

  @override
  State<AdminCurtainEdit> createState() => _AdminCurtainEditState();
}

class _AdminCurtainEditState extends State<AdminCurtainEdit> {
  final _formKey = GlobalKey<FormState>();

  // ---------- Dropdown ----------
  String typeValue = '뮤지컬';
  String gradeValue = 'VIP';
  String areaValue = 'A구역';

  final List<String> typeItems = const ['뮤지컬', '콘서트', '연극', '클래식'];
  final List<String> gradeItems = const ['VIP', 'R', 'S', 'A', 'B'];
  final List<String> areaItems = const ['A구역', 'B구역', 'C구역', 'D구역', 'E구역', 'F구역'];

  // ---------- TextField ----------
  late final TextEditingController titleCtrl;
  late final TextEditingController locationCtrl;
  late final TextEditingController placeCtrl;
  late final TextEditingController showDateCtrl;
  late final TextEditingController showTimeCtrl;
  late final TextEditingController castCtrl;

  @override
  void initState() {
    super.initState();

    // ✅ 초기값 주입
    final d = widget.initialData;

    typeValue = (d['type'] ?? '뮤지컬').toString();
    gradeValue = (d['grade'] ?? 'VIP').toString();
    areaValue = (d['area'] ?? 'A구역').toString();

    // items에 없는 값이 들어오면 기본값으로 안전 처리
    if (!typeItems.contains(typeValue)) typeValue = typeItems.first;
    if (!gradeItems.contains(gradeValue)) gradeValue = gradeItems.first;
    if (!areaItems.contains(areaValue)) areaValue = areaItems.first;

    titleCtrl = TextEditingController(text: (d['title'] ?? '').toString());
    locationCtrl = TextEditingController(text: (d['location'] ?? '').toString());
    placeCtrl = TextEditingController(text: (d['place'] ?? '').toString());
    showDateCtrl = TextEditingController(text: (d['show_date'] ?? '').toString());
    showTimeCtrl = TextEditingController(text: (d['show_time'] ?? '').toString());
    castCtrl = TextEditingController(text: (d['show_cast'] ?? '').toString());
  }

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

  void _submitUpdate() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // ✅ 기존 데이터 복사 + 수정값 덮어쓰기 (id/seq 같은 값 유지 가능)
    final updated = Map<String, dynamic>.from(widget.initialData);

    updated.addAll({
      'type': typeValue,
      'grade': gradeValue,
      'area': areaValue,
      'title': titleCtrl.text.trim(),
      'location': locationCtrl.text.trim(),
      'place': placeCtrl.text.trim(),
      'show_date': showDateCtrl.text.trim(),
      'show_time': showTimeCtrl.text.trim(),
      'show_cast': castCtrl.text.trim(),
    });

    Navigator.pop(context, updated);
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
                                    Expanded(
                                      child: _dashDropdown(
                                        label: 'grade',
                                        value: gradeValue,
                                        items: gradeItems,
                                        onChanged: (v) => setState(() => gradeValue = v),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _dashDropdown(
                                        label: 'area',
                                        value: areaValue,
                                        items: areaItems,
                                        onChanged: (v) => setState(() => areaValue = v),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // 4줄: show_date + show_time
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

                                // 5줄: show_cast
                                _dashTextField(
                                  label: 'show_cast',
                                  controller: castCtrl,
                                  hint: '출연진 (예: 정선아, ...)',
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
}
