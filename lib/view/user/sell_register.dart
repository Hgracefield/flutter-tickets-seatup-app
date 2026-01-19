import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/curtain.dart';
import 'package:seatup_app/vm/curtain_list_provider.dart';
import 'package:seatup_app/vm/title_notifier.dart';

class SellRegister extends ConsumerStatefulWidget {
  const SellRegister({super.key});

  @override
  ConsumerState<SellRegister> createState() => _SellRegisterState();
}

class _SellRegisterState extends ConsumerState<SellRegister> {
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
  void initState() {
    super.initState();
    // final c = curtainListProvider
  }

  @override
  Widget build(BuildContext context) {
    final titleAsync = ref.watch(titleNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text('판매 등록'), centerTitle: true),
      body: Center(
        child: Column(
          children: [
            titleAsync.when(
              data: (data) {
              return  _titleDropdown(
              label: '제목',
              value: titleAsync.value!.first.title_contents,
              items: titleAsync.value!.map((e) => e.title_contents).toList(),
              onChanged: (v) => setState(() => typeValue = v),
            );
              }, 
              error: (error, stackTrace) => Center(), 
              loading: () => Center(),)
            
          ],
        ),
      ),
    );
  } // build

  // === Widgets ===

  Widget _titleDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dropdownLabel(label),
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

  Widget _dropdownLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w800,
      color: Color(0xFF2F57C9),
    ),
  );

  // === Functions ===

}
