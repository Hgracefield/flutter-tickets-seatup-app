import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:get_storage/get_storage.dart'; 

// 모델 임포트 (기존 user.dart 그대로 사용)
import 'package:seatup_app/model/curtain.dart';
import 'package:seatup_app/model/curtain_list.dart' as model_list;
import 'package:seatup_app/model/grade.dart';
import 'package:seatup_app/model/area.dart';
import 'package:seatup_app/model/post.dart';

// 뷰모델(Notifier) 임포트
import 'package:seatup_app/vm/curtain_notifier.dart';
import 'package:seatup_app/vm/payment_notifier.dart';
import 'package:seatup_app/vm/grade_notifier.dart';
import 'package:seatup_app/vm/area_notifier.dart';
import 'package:seatup_app/vm/post_notifier.dart';
import 'package:seatup_app/vm/user_notifier.dart';

import 'ticket_result.dart'; 

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
    _scheduleFuture = ref.read(curtainNotifierProvider.notifier)
        .searchCurtain(widget.item.title_contents);
  }

  @override
  void dispose() {
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  int _getMaxPrice(List<Grade> grades, String? selectedGradeBit) {
    if (selectedGradeBit == null) return 0;
    try {
      final matched = grades.firstWhere((e) => e.bit.toString() == selectedGradeBit);
      return matched.grade_price;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentProvider);
    final notifier = ref.read(paymentProvider.notifier);
    final gradeAsync = ref.watch(gradeNotifierProvider);
    final areaAsync = ref.watch(areaNotifierProvider);
    
    // 1. 유저 정보 감시
    final userAsync = ref.watch(userNotifierProvider);
    final box = GetStorage();

    // 2. [에러 방지 핵심 로직] 
    // user.dart를 수정하지 않고, 여기서 데이터를 읽을 때 강제로 int 변환을 시도합니다.
    // Provider에서 먼저 찾고, 없으면 Storage에서 찾습니다.
    final dynamic rawId = userAsync.value?.user_id ?? box.read('user_id');
    final int currentUserId = int.tryParse(rawId?.toString() ?? "0") ?? 0;

    // 디버그용 출력 (로그캣에서 확인해 보세요)
    print("------- 버튼 체크 -------");
    print("유저ID: $currentUserId");
    print("구역선택: ${state.selectedRow}");
    print("가격에러: $_isPriceError");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("예매 정보 선택", style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Curtain>>(
        future: _scheduleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("상영 정보가 없습니다."));

          final allSchedules = snapshot.data!;
          final availableDates = allSchedules.map((c) => c.curtain_date).toSet().toList()..sort();
          String? selDateStr = state.selectedDate != null ? DateFormat('yyyy-MM-dd').format(state.selectedDate!) : null;

          final availableTimes = allSchedules
              .where((c) => c.curtain_date == selDateStr)
              .map((c) => c.curtain_time.length >= 5 ? c.curtain_time.substring(0, 5) : c.curtain_time)
              .toSet().toList()..sort();

          final currentSchedules = allSchedules.where((c) {
            final fTime = c.curtain_time.length >= 5 ? c.curtain_time.substring(0, 5) : c.curtain_time;
            return c.curtain_date == selDateStr && fTime == state.selectedTime;
          }).toList();

          return Stack(
            children: [
              GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 150),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMovieSummaryRealistic(),
                      const SizedBox(height: 25),
                      _sectionTitle("이용하실 서비스를 선택해주세요"),
                      _buildModeSelector(state, notifier),
                      if (state.selectedMode != null) _buildDateSection(state, notifier, availableDates),
                      if (state.selectedDate != null) ...[
                        _sectionTitle("공연 시간"),
                        _buildTimeGrid(state, notifier, availableTimes),
                      ],
                      if (state.selectedTime != null) ...[
                        _sectionTitle("좌석 등급"),
                        gradeAsync.when(
                          data: (gradeList) {
                            final filtered = gradeList.where((g) => currentSchedules.any((c) => (c.curtain_grade & g.bit) != 0)).toList();
                            return _buildGradeSelector(state, notifier, filtered);
                          },
                          loading: () => const LinearProgressIndicator(),
                          error: (e, s) => const SizedBox(),
                        ),
                      ],
                      if (state.selectedGrade != null) ...[
                        _sectionTitle("좌석 구역"),
                        areaAsync.when(
                          data: (areaList) {
                            final int gradeBit = int.tryParse(state.selectedGrade ?? '0') ?? 0;
                            final filtered = areaList.where((a) => currentSchedules.any((c) => (c.curtain_grade & gradeBit) != 0 && (c.curtain_area & a.bit) != 0)).toList();
                            return _buildAreaSelector(state, notifier, filtered);
                          },
                          loading: () => const LinearProgressIndicator(),
                          error: (e, s) => const SizedBox(),
                        ),
                        const SizedBox(height: 25),
                        _sectionTitle("인원 선택"),
                        _buildQuantityStepper(state, notifier),
                      ],
                      if (state.selectedRow != null && state.selectedMode == 1) ...[
                        gradeAsync.when(
                          data: (list) => _buildSellInputSection(_getMaxPrice(list, state.selectedGrade)),
                          loading: () => const SizedBox(),
                          error: (e, s) => const SizedBox(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // 버튼 활성화 로직이 들어있는 바텀 바
              if (state.selectedRow != null) 
                _buildFloatingBottomBar(state, currentSchedules, currentUserId),
            ],
          );
        },
      ),
    );
  }

  // --- UI 컴포넌트 ---

  Widget _buildMovieSummaryRealistic() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(children: [
        ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(widget.item.curtain_pic, width: 85, height: 115, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 85, height: 115, color: bgGrey, child: const Icon(Icons.image)))),
        const SizedBox(width: 20),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: accentColor.withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: const Text("공연정보", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.brown))),
          const SizedBox(height: 8),
          Text(widget.item.title_contents, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Row(children: [const Icon(Icons.location_on, size: 14, color: Colors.grey), const SizedBox(width: 4), Expanded(child: Text(widget.item.place_name, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis))]),
        ])),
      ]),
    );
  }

  Widget _buildModeSelector(PaymentState state, PaymentNotifier notifier) {
    return Row(children: [0, 1].map((i) => Expanded(child: GestureDetector(onTap: () => notifier.setMode(i), child: Container(margin: EdgeInsets.only(right: i == 0 ? 10 : 0), padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(color: state.selectedMode == i ? accentColor : bgGrey, borderRadius: BorderRadius.circular(12)), child: Center(child: Text(i == 0 ? "구매하기" : "판매하기", style: TextStyle(color: Colors.black, fontWeight: state.selectedMode == i ? FontWeight.bold : FontWeight.normal))))))).toList());
  }

  Widget _buildDateSection(PaymentState state, PaymentNotifier notifier, List<String> availableDates) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_sectionTitle("관람 날짜"), IconButton(icon: const Icon(Icons.calendar_month_outlined, color: Colors.black54), onPressed: () => _showCalendarModal(state, notifier, availableDates))]),
      SizedBox(height: 85, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: availableDates.length, itemBuilder: (context, index) {
        DateTime date = DateTime.parse(availableDates[index]);
        bool isSelected = isSameDay(state.selectedDate, date);
        return GestureDetector(onTap: () => notifier.setDate(date), child: Container(width: 60, margin: const EdgeInsets.only(right: 12), decoration: BoxDecoration(color: isSelected ? accentColor : bgGrey, borderRadius: BorderRadius.circular(12)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(DateFormat('E', 'ko_KR').format(date), style: TextStyle(fontSize: 12, color: isSelected ? Colors.black : Colors.grey)), const SizedBox(height: 5), Text("${date.day}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black))])));
      })),
    ]);
  }

  Widget _buildTimeGrid(PaymentState state, PaymentNotifier notifier, List<String> times) {
    return GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.2), itemCount: times.length, itemBuilder: (context, index) {
      final t = times[index];
      return GestureDetector(onTap: () => notifier.setTime(t), child: Container(decoration: BoxDecoration(color: state.selectedTime == t ? accentColor : bgGrey, borderRadius: BorderRadius.circular(10)), child: Center(child: Text(t, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)))));
    });
  }

  Widget _buildGradeSelector(PaymentState state, PaymentNotifier notifier, List<Grade> filteredGrades) {
    return Wrap(spacing: 10, children: filteredGrades.map((g) {
      bool isSelected = state.selectedGrade == g.bit.toString();
      return GestureDetector(onTap: () => notifier.setGrade(g.bit.toString()), child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), decoration: BoxDecoration(color: isSelected ? accentColor : bgGrey, borderRadius: BorderRadius.circular(8)), child: Text(g.grade_name, style: const TextStyle(color: Colors.black))));
    }).toList());
  }

  Widget _buildAreaSelector(PaymentState state, PaymentNotifier notifier, List<Area> filteredAreas) {
    return Wrap(spacing: 10, runSpacing: 10, children: filteredAreas.map((a) {
      bool isSelected = state.selectedRow == a.area_number;
      return GestureDetector(onTap: () => notifier.setRow(a.area_number), child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), decoration: BoxDecoration(color: isSelected ? accentColor : bgGrey, borderRadius: BorderRadius.circular(10)), child: Text(a.area_number, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black))));
    }).toList());
  }

  Widget _buildQuantityStepper(PaymentState state, PaymentNotifier notifier) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), decoration: BoxDecoration(color: bgGrey, borderRadius: BorderRadius.circular(15)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("관람권 수량", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)), Row(children: [IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => notifier.setQuantity(state.quantity - 1)), Text("${state.quantity}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)), IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => notifier.setQuantity(state.quantity + 1))])]));
  }

  Widget _buildSellInputSection(int maxPrice) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle("판매 정보 입력"),
      Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.05), borderRadius: BorderRadius.circular(8)), child: Text("해당 등급 정가: ${NumberFormat('#,###').format(maxPrice)}원 이하로 입력 가능", style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold))),
      const SizedBox(height: 15),
      TextField(
        controller: _priceController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.black),
        onChanged: (v) {
          int inputPrice = int.tryParse(v) ?? 0;
          setState(() => _isPriceError = inputPrice > maxPrice);
        },
        decoration: InputDecoration(hintText: "판매 가격 입력", filled: true, fillColor: bgGrey, errorText: _isPriceError ? "정가를 초과할 수 없습니다." : null, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), suffixText: "원"),
      ),
      const SizedBox(height: 15),
      TextField(controller: _descController, maxLines: 3, style: const TextStyle(color: Colors.black), decoration: InputDecoration(hintText: "상세 설명 (연석 여부 등)", filled: true, fillColor: bgGrey, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
    ]);
  }

  Widget _buildFloatingBottomBar(PaymentState state, List<Curtain> currentSchedules, int currentUserId) {
    String dateStr = state.selectedDate != null ? DateFormat('MM.dd').format(state.selectedDate!) : "";
    
    // 버튼 활성화 로직
    // 구매/판매 관계 없이 로그인이 되어 있어야 하고(ID != 0), 구역이 선택되어야 함.
    bool commonCondition = currentUserId != 0 && state.selectedRow != null;
    
    // 판매 모드일 때는 추가로 가격 입력이 필요함
    bool isSellMode = state.selectedMode == 1;
    bool isButtonEnabled = commonCondition;
    if (isSellMode) {
      isButtonEnabled = commonCondition && _priceController.text.isNotEmpty && !_isPriceError;
    }

    return Align(alignment: Alignment.bottomCenter, child: Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))]),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text("$dateStr | ${state.selectedTime ?? ''}", style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 4),
          Text("${state.selectedRow ?? ''} | ${state.quantity}매", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
        ]),
        const Spacer(),
        ElevatedButton(
          onPressed: isButtonEnabled ? () async {
            if (!isSellMode) {
              // 구매: 검색 수행
              await ref.read(postNotifierProvider.notifier).fetchFilteredPosts(
                curtainId: currentSchedules.first.curtain_id!,
                date: DateFormat('yyyy-MM-dd').format(state.selectedDate!),
                time: state.selectedTime!,
                gradeBit: int.parse(state.selectedGrade!),
                area: state.selectedRow!,
              );
              if (!mounted) return;
              Navigator.push(context, MaterialPageRoute(builder: (c) => const TicketResultScreen()));
            } else {
              // 판매: 등록 수행
              final areaList = ref.read(areaNotifierProvider).value ?? [];
              final gradeList = ref.read(gradeNotifierProvider).value ?? [];
              
              Post newPost = Post(
                post_user_id: currentUserId,
                post_curtain_id: currentSchedules.first.curtain_id!,
                post_area: areaList.firstWhere((a) => a.area_number == state.selectedRow).area_seq!,
                post_grade: gradeList.firstWhere((g) => g.bit.toString() == state.selectedGrade).grade_seq!,
                post_quantity: state.quantity,
                post_price: int.parse(_priceController.text),
                post_desc: _descController.text,
              );

              final result = await ref.read(postNotifierProvider.notifier).insertPost(newPost);
              if (result == "OK" && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("판매 티켓이 등록되었습니다.")));
              }
            }
          } : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor, foregroundColor: Colors.black, 
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
            elevation: 0,
            disabledBackgroundColor: Colors.grey.shade300, // 비활성화 색상
          ),
          child: Text(isSellMode ? "등록하기" : "티켓 검색", style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ]),
    ));
  }

  Widget _sectionTitle(String title) => Padding(padding: const EdgeInsets.only(bottom: 12, top: 15), child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)));

  void _showCalendarModal(PaymentState state, PaymentNotifier notifier, List<String> availableDates) {
    showModalBottomSheet(context: context, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))), builder: (context) => Container(padding: const EdgeInsets.all(20), height: 450, child: Column(children: [Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))), const SizedBox(height: 20), TableCalendar(locale: 'ko_KR', firstDay: DateTime.now(), lastDay: DateTime.now().add(const Duration(days: 90)), focusedDay: state.selectedDate ?? DateTime.now(), headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true), calendarStyle: CalendarStyle(selectedDecoration: BoxDecoration(color: accentColor, shape: BoxShape.circle), selectedTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold), todayDecoration: BoxDecoration(color: accentColor.withOpacity(0.3), shape: BoxShape.circle)), selectedDayPredicate: (day) => isSameDay(state.selectedDate, day), onDaySelected: (selectedDay, focusedDay) { String dateStr = DateFormat('yyyy-MM-dd').format(selectedDay); if (availableDates.contains(dateStr)) { notifier.setDate(selectedDay); Navigator.pop(context); } }, )])));
  }
}