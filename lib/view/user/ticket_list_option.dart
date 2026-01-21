import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

// 모델 및 Notifier 임포트 (경로 확인 필수!)
import 'package:seatup_app/model/curtain.dart';
import 'package:seatup_app/model/curtain_list.dart' as model_list;
import 'package:seatup_app/model/grade.dart';
import 'package:seatup_app/model/area.dart';
import 'package:seatup_app/vm/curtain_notifier.dart';
import 'package:seatup_app/vm/payment_notifier.dart';
import 'package:seatup_app/vm/grade_notifier.dart';
import 'package:seatup_app/vm/area_notifier.dart';
import 'package:seatup_app/vm/post_notifier.dart';
import 'ticket_result.dart'; // 같은 폴더에 있다고 가정

class TicketListOption extends ConsumerStatefulWidget {
  final model_list.CurtainList item;
  const TicketListOption({super.key, required this.item});

  @override
  ConsumerState<TicketListOption> createState() => _TicketListOptionState();
}

class _TicketListOptionState extends ConsumerState<TicketListOption> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final Color accentColor = const Color(0xFFF8DE7D);
  final Color bgGrey = const Color(0xFFF8F8F8);
  
  late Future<List<Curtain>> _scheduleFuture;
  bool _isPriceError = false;

  @override
  void initState() {
    super.initState();
    _scheduleFuture = ref.read(curtainNotifierProvider.notifier).searchCurtain(widget.item.title_contents);
  }

  int _getMaxPrice(List<Grade> grades, String? selectedGradeBit) {
    if (selectedGradeBit == null) return 0;
    try {
      return grades.firstWhere((e) => e.bit.toString() == selectedGradeBit).grade_price;
    } catch (e) { return 0; }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentProvider);
    final notifier = ref.read(paymentProvider.notifier);
    final gradeAsync = ref.watch(gradeNotifierProvider);
    final areaAsync = ref.watch(areaNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)), title: Text(widget.item.title_contents, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
      body: FutureBuilder<List<Curtain>>(
        future: _scheduleFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final all = snapshot.data!;
          final dates = all.map((c) => c.curtain_date).toSet().toList()..sort();
          String? selD = state.selectedDate != null ? DateFormat('yyyy-MM-dd').format(state.selectedDate!) : null;
          final times = all.where((c) => c.curtain_date == selD).map((c) => c.curtain_time.substring(0, 5)).toSet().toList()..sort();
          final current = all.where((c) => c.curtain_date == selD && c.curtain_time.startsWith(state.selectedTime ?? "NONE")).toList();

          return Stack(children: [
            SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 10, 20, 150), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildSummary(), _buildMode(state, notifier),
              if (state.selectedMode != null) _buildDate(state, notifier, dates),
              if (state.selectedDate != null) _buildTimes(state, notifier, times),
              if (state.selectedTime != null) gradeAsync.when(data: (list) => _buildGrades(state, notifier, list.where((g) => current.any((c) => (c.curtain_grade & g.bit) != 0)).toList()), loading: () => const SizedBox(), error: (e, s) => const SizedBox()),
              if (state.selectedGrade != null) areaAsync.when(data: (list) => _buildAreas(state, notifier, list.where((a) => current.any((c) => (c.curtain_grade & int.parse(state.selectedGrade!)) != 0 && (c.curtain_area & a.bit) != 0)).toList()), loading: () => const SizedBox(), error: (e, s) => const SizedBox()),
              if (state.selectedRow != null && state.selectedMode == 1) gradeAsync.when(data: (list) => _buildSellInfo(_getMaxPrice(list, state.selectedGrade)), loading: () => const SizedBox(), error: (e, s) => const SizedBox()),
            ])),
            if (state.selectedRow != null) _buildBottomBar(state, current),
          ]);
        },
      ),
    );
  }

  // --- UI Helper Widgets (Simplified for clarity) ---
  Widget _buildSummary() => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]), child: Row(children: [ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(widget.item.curtain_pic, width: 80, height: 110, fit: BoxFit.cover)), const SizedBox(width: 15), Expanded(child: Text(widget.item.title_contents, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))]));
  Widget _buildMode(PaymentState s, PaymentNotifier n) => Row(children: [0,1].map((i) => Expanded(child: GestureDetector(onTap: () => n.setMode(i), child: Container(margin: const EdgeInsets.only(top: 20, right: 5), padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: s.selectedMode == i ? accentColor : bgGrey, borderRadius: BorderRadius.circular(12)), child: Center(child: Text(i==0?"구매":"판매")))))).toList());
  Widget _buildDate(PaymentState s, PaymentNotifier n, List<String> d) => Container(height: 85, margin: const EdgeInsets.only(top: 20), child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: d.length, itemBuilder: (c, i) { DateTime dt = DateTime.parse(d[i]); bool sel = isSameDay(s.selectedDate, dt); return GestureDetector(onTap: () => n.setDate(dt), child: Container(width: 60, margin: const EdgeInsets.only(right: 10), decoration: BoxDecoration(color: sel ? accentColor : bgGrey, borderRadius: BorderRadius.circular(12)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(DateFormat('E', 'ko_KR').format(dt)), Text("${dt.day}", style: const TextStyle(fontWeight: FontWeight.bold))]))); }));
  Widget _buildTimes(PaymentState s, PaymentNotifier n, List<String> t) => GridView.count(shrinkWrap: true, crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.2, children: t.map((time) => GestureDetector(onTap: () => n.setTime(time), child: Container(decoration: BoxDecoration(color: s.selectedTime == time ? accentColor : bgGrey, borderRadius: BorderRadius.circular(10)), child: Center(child: Text(time))))).toList());
  Widget _buildGrades(PaymentState s, PaymentNotifier n, List<Grade> g) => Wrap(spacing: 10, children: g.map((grade) => GestureDetector(onTap: () => n.setGrade(grade.bit.toString()), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: s.selectedGrade == grade.bit.toString() ? accentColor : bgGrey, borderRadius: BorderRadius.circular(8)), child: Text(grade.grade_name)))).toList());
  Widget _buildAreas(PaymentState s, PaymentNotifier n, List<Area> a) => Wrap(spacing: 10, children: a.map((area) => GestureDetector(onTap: () => n.setRow(area.area_number), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: s.selectedRow == area.area_number ? accentColor : bgGrey, borderRadius: BorderRadius.circular(10)), child: Text(area.area_number)))).toList());
  Widget _buildSellInfo(int max) => Column(children: [TextField(controller: _priceController, onChanged: (v) => setState(() => _isPriceError = (int.tryParse(v)??0) > max), decoration: InputDecoration(hintText: "가격", errorText: _isPriceError?"정가 초과":null)), TextField(controller: _descController, decoration: const InputDecoration(hintText: "설명"))]);
  Widget _buildBottomBar(PaymentState s, List<Curtain> c) => Align(alignment: Alignment.bottomCenter, child: Container(padding: const EdgeInsets.all(20), color: Colors.white, child: ElevatedButton(onPressed: _isPriceError?null:()async{ if(s.selectedMode == 0){ await ref.read(postNotifierProvider.notifier).fetchFilteredPosts(curtainId: c.first.curtain_id!, date: DateFormat('yyyy-MM-dd').format(s.selectedDate!), time: s.selectedTime!, gradeBit: int.parse(s.selectedGrade!), area: s.selectedRow!); Navigator.push(context, MaterialPageRoute(builder: (c) => const TicketResultScreen())); } }, style: ElevatedButton.styleFrom(backgroundColor: accentColor, minimumSize: const Size(double.infinity, 60)), child: const Text("확인"))));
}