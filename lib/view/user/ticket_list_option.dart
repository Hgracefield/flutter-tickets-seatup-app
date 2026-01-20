import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seatup_app/model/curtain.dart';
import 'package:seatup_app/model/curtain_list.dart' as model_list;
import 'package:seatup_app/vm/curtain_notifier.dart';
import 'package:seatup_app/vm/payment_notifier.dart';
import 'package:table_calendar/table_calendar.dart';

class TicketListOption extends ConsumerStatefulWidget {
  final model_list.CurtainList item;
  const TicketListOption({super.key, required this.item});

  @override
  ConsumerState<TicketListOption> createState() => _TicketListOptionState();
}

class _TicketListOptionState extends ConsumerState<TicketListOption> {
  final TextEditingController _priceController = TextEditingController();
  final Color accentColor = const Color(0xFFF8DE7D);
  final Color bgGrey = const Color(0xFFF8F8F8);

  late Future<List<Curtain>> _scheduleFuture;

  @override
  void initState() {
    super.initState();
    // 기존 Notifier를 사용하여 해당 작품의 전체 스케줄 로드
    _scheduleFuture = ref.read(curtainNotifierProvider.notifier)
        .searchCurtain(widget.item.title_contents);
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  // 달력 모달 (비활성 날짜 처리 포함)
  void _showCalendarModal(PaymentState state, PaymentNotifier notifier, List<String> availableDates) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: 450,
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            TableCalendar(
              locale: 'ko_KR',
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 90)),
              focusedDay: state.selectedDate ?? DateTime.now(),
              headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                selectedTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                todayDecoration: BoxDecoration(color: accentColor.withOpacity(0.3), shape: BoxShape.circle),
                // 공연이 없는 날짜는 흐리게 표시
                outsideTextStyle: const TextStyle(color: Colors.grey),
                disabledTextStyle: const TextStyle(color: Colors.black12),
              ),
              selectedDayPredicate: (day) => isSameDay(state.selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                // 실제 데이터가 있는 날짜인지 확인 후 선택
                String dateStr = DateFormat('yyyy-MM-dd').format(selectedDay);
                if (availableDates.contains(dateStr)) {
                  notifier.setDate(selectedDay);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("해당 날짜에는 공연이 없습니다."), duration: Duration(seconds: 1)),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentProvider);
    final notifier = ref.read(paymentProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text("예매 정보 선택", style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Curtain>>(
        future: _scheduleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("공연 정보가 없습니다."));

          final allSchedules = snapshot.data!;
          
          // 1. 날짜 필터링 (고유 날짜만)
          final availableDates = allSchedules.map((c) => c.curtain_date).toSet().toList()..sort();
          String? selDateStr = state.selectedDate != null ? DateFormat('yyyy-MM-dd').format(state.selectedDate!) : null;

          // 2. 시간 필터링 (선택 날짜 기준)
          final availableTimes = allSchedules
              .where((c) => c.curtain_date == selDateStr)
              .map((c) {
                // "14:00:00" -> "14:00" (초 단위 제거)
                if (c.curtain_time.length >= 5) {
                  return c.curtain_time.substring(0, 5);
                }
                  return c.curtain_time;
    })
    .toSet().toList()..sort();

          // 3. 구역 필터링 (날짜 + 시간 기준)
          final availableAreas = allSchedules
              .where((c) => c.curtain_date == selDateStr && c.curtain_time == state.selectedTime)
              .map((c) => c.curtain_area.toString())
              .toSet().toList()..sort();

          return Stack(
            children: [
              GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMovieSummary(),
                      const SizedBox(height: 25),
                      _sectionTitle("서비스 모드"),
                      _buildModeSelector(state, notifier),
                      
                      if (state.selectedMode != null) ...[
                        _buildDateSection(state, notifier, availableDates),
                      ],

                      if (state.selectedDate != null) ...[
                        _sectionTitle("상영 시간"),
                        _buildTimeGrid(state, notifier, availableTimes),
                      ],

                      if (state.selectedTime != null) ...[
                        _sectionTitle("좌석 구역"),
                        _buildAreaSelector(state, notifier, availableAreas),
                        const SizedBox(height: 25),
                        _sectionTitle("인원 선택"),
                        _buildQuantityStepper(state, notifier),
                      ],

                      if (state.selectedRow != null && state.selectedMode == 1) ...[
                        _sectionTitle("판매 가격 설정"),
                        _buildSellInput(),
                      ],
                    ],
                  ),
                ),
              ),
              if (state.selectedRow != null) _buildFloatingBottomBar(state),
            ],
          );
        },
      ),
    );
  }

  // --- UI 구성 요소 (테두리 제거 반영) ---

  Widget _buildMovieSummary() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: bgGrey, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(widget.item.curtain_pic, width: 60, height: 80, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 60, height: 80, color: Colors.grey[200])),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.item.title_contents, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(widget.item.place_name, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector(PaymentState state, PaymentNotifier notifier) {
    return Row(
      children: [0, 1].map((i) {
        bool sel = state.selectedMode == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => notifier.setMode(i),
            child: Container(
              margin: EdgeInsets.only(right: i == 0 ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: sel ? accentColor : bgGrey,
                borderRadius: BorderRadius.circular(12),
                border: null, // [수정] 테두리 제거
              ),
              child: Center(child: Text(i == 0 ? "구매하기" : "판매하기", style: TextStyle(fontWeight: sel ? FontWeight.bold : FontWeight.normal, color: Colors.black))),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateSection(PaymentState state, PaymentNotifier notifier, List<String> availableDates) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionTitle("관람 날짜"),
            IconButton(
              icon: const Icon(Icons.calendar_month_outlined, color: Colors.black54),
              onPressed: () => _showCalendarModal(state, notifier, availableDates),
            )
          ],
        ),
        SizedBox(
          height: 85,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: availableDates.length,
            itemBuilder: (context, index) {
              DateTime date = DateTime.parse(availableDates[index]);
              bool isSelected = isSameDay(state.selectedDate, date);
              String weekday = DateFormat('E', 'ko_KR').format(date);
              
              return GestureDetector(
                onTap: () => notifier.setDate(date),
                child: Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? accentColor : bgGrey,
                    borderRadius: BorderRadius.circular(12),
                    border: null, // [수정] 테두리 제거
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(weekday, style: TextStyle(fontSize: 12, color: isSelected ? Colors.black : Colors.grey[600])),
                      const SizedBox(height: 5),
                      Text("${date.day}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeGrid(PaymentState state, PaymentNotifier notifier, List<String> times) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.2,
      ),
      itemCount: times.length,
      itemBuilder: (context, index) {
        final t = times[index];
        bool isSelected = state.selectedTime == t;

        return GestureDetector(
          onTap: () => notifier.setTime(t),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? accentColor : bgGrey,
              borderRadius: BorderRadius.circular(10),
              border: null, // [수정] 테두리 제거
            ),
            child: Center(
              child: Text(t, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAreaSelector(PaymentState state, PaymentNotifier notifier, List<String> areas) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: areas.map((area) {
        String label = "$area구역";
        bool isSelected = state.selectedRow == label;
        return GestureDetector(
          onTap: () => notifier.setRow(label),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? accentColor : bgGrey,
              borderRadius: BorderRadius.circular(10),
              border: null, // [수정] 테두리 제거
            ),
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuantityStepper(PaymentState state, PaymentNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: bgGrey, borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("관람권 수량", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
          Row(
            children: [
              _stepBtn(Icons.remove, () => notifier.setQuantity(state.quantity - 1)),
              SizedBox(width: 40, child: Center(child: Text("${state.quantity}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)))),
              _stepBtn(Icons.add, () => notifier.setQuantity(state.quantity + 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey[400]!)),
      child: Icon(icon, size: 18, color: Colors.black),
    ),
  );

  Widget _buildFloatingBottomBar(PaymentState state) {
    String dateStr = state.selectedDate != null ? DateFormat('MM.dd').format(state.selectedDate!) : "";
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 100,
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("$dateStr | ${state.selectedTime ?? ''} | ${state.selectedRow ?? ''}", style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 4),
                Text("총 ${state.quantity}매 선택", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor, foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(state.selectedMode == 0 ? "티켓 찾기" : "판매 등록", style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12, top: 10),
    child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
  );

  Widget _buildSellInput() {
    return TextField(
      controller: _priceController,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: "금액 입력", filled: true, fillColor: bgGrey,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        suffixText: "원",
        suffixStyle: const TextStyle(color: Colors.black),
      ),
    );
  }
}