import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seatup_app/vm/payment_notifier.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:seatup_app/model/curtain_list.dart';

class TicketListOption extends ConsumerStatefulWidget {
  final CurtainList item;
  const TicketListOption({super.key, required this.item});

  @override
  ConsumerState<TicketListOption> createState() => _TicketListOptionState();
}

class _TicketListOptionState extends ConsumerState<TicketListOption> {
  final TextEditingController _priceController = TextEditingController();
  final Color accentColor = const Color(0xFFF8DE7D);
  final Color bgGrey = const Color(0xFFF8F8F8);

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  // 달력 모달 팝업
  void _showCalendarModal(PaymentState state, PaymentNotifier notifier) {
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
                defaultTextStyle: const TextStyle(color: Colors.black),
              ),
              selectedDayPredicate: (day) => isSameDay(state.selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                notifier.setDate(selectedDay);
                Navigator.pop(context);
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
      body: Stack(
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
                    _buildDateSection(state, notifier),
                  ],

                  if (state.selectedDate != null) ...[
                    _sectionTitle("상영 시간"),
                    _buildTimeGrid(state, notifier),
                  ],

                  if (state.selectedTime != null) ...[
                    _sectionTitle("좌석 구역"),
                    _buildRowSelector(state, notifier),
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
          // 하단 버튼 바
          if (state.selectedRow != null) _buildFloatingBottomBar(state),
        ],
      ),
    );
  }

  // 1. 작품 요약 정보 카드
  Widget _buildMovieSummary() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bgGrey,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(widget.item.curtain_pic, width: 60, height: 80, fit: BoxFit.cover),
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

  // 2. 가로 슬라이드 날짜 + 달력 아이콘
  Widget _buildDateSection(PaymentState state, PaymentNotifier notifier) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionTitle("관람 날짜"),
            IconButton(
              icon: const Icon(Icons.calendar_month_outlined, color: Colors.black54),
              onPressed: () => _showCalendarModal(state, notifier),
            )
          ],
        ),
        SizedBox(
          height: 85,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 14,
            itemBuilder: (context, index) {
              DateTime date = DateTime.now().add(Duration(days: index));
              bool isSelected = isSameDay(state.selectedDate, date);
              String weekday = DateFormat('E', 'ko_KR').format(date);
              
              return GestureDetector(
                onTap: () => notifier.setDate(date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 60,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? accentColor : bgGrey,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? accentColor : Colors.transparent),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(weekday, style: TextStyle(fontSize: 12, color: isSelected ? Colors.black : Colors.grey[600])),
                      const SizedBox(height: 5),
                      Text("${date.day}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  // 3. 리얼한 시간대 그리드 (상영관 정보 포함)
  Widget _buildTimeGrid(PaymentState state, PaymentNotifier notifier) {
    List<Map<String, String>> times = [
      {"time": "10:30", "hall": "1관", "seat": "45석"},
      {"time": "13:20", "hall": "1관", "seat": "12석"},
      {"time": "16:10", "hall": "2관", "seat": "매진"},
      {"time": "19:00", "hall": "1관", "seat": "28석"},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.8,
      ),
      itemCount: times.length,
      itemBuilder: (context, index) {
        final t = times[index];
        bool isSoldOut = t['seat'] == "매진";
        bool isSelected = state.selectedTime == t['time'];

        return GestureDetector(
          onTap: isSoldOut ? null : () => notifier.setTime(t['time']!),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? accentColor : (isSoldOut ? Colors.grey[100] : bgGrey),
              borderRadius: BorderRadius.circular(10),
              border: isSelected ? Border.all(color: Colors.black, width: 0.5) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(t['time']!, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isSoldOut ? Colors.grey : Colors.black)),
                Text("${t['hall']} | ${t['seat']}", style: TextStyle(fontSize: 10, color: isSoldOut ? Colors.grey : Colors.black54)),
              ],
            ),
          ),
        );
      },
    );
  }

  // 4. 세련된 수량 스태퍼
  Widget _buildQuantityStepper(PaymentState state, PaymentNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: bgGrey, borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("일반 관람권", style: TextStyle(fontWeight: FontWeight.w600)),
          Row(
            children: [
              _stepBtn(Icons.remove, () => notifier.setQuantity(state.quantity - 1)),
              SizedBox(width: 40, child: Center(child: Text("${state.quantity}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
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
      child: Icon(icon, size: 18, color: Colors.black87),
    ),
  );

  // 5. 하단 요약 플로팅 바
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
                Text("총 ${state.quantity}매 선택", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  // 공통 위젯들
  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12, top: 10),
    child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
  );

  Widget _buildModeSelector(PaymentState state, PaymentNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
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
                  border: sel ? Border.all(color: Colors.black, width: 0.5) : null,
                ),
                child: Center(child: Text(i == 0 ? "구매하기" : "판매하기", style: TextStyle(fontWeight: sel ? FontWeight.bold : FontWeight.normal))),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRowSelector(PaymentState state, PaymentNotifier notifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: ["A열", "B열", "C열", "D열"].map((r) {
        bool isSelected = state.selectedRow == r;
        return GestureDetector(
          onTap: () => notifier.setRow(r),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.2,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? accentColor : bgGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(r)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSellInput() {
    return TextField(
      controller: _priceController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: "금액 입력", filled: true, fillColor: bgGrey,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        suffixText: "원",
      ),
    );
  }
}