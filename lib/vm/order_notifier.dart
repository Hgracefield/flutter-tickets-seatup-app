import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderNotifier extends AsyncNotifier<void> {
  @override
  build() {}

    // 티켓번호 만드는 함수
  String ticketNumber(String date , int postSeq , int curtainId){
    final List<String> value = date.split('-');
    String dateNumber = '';
    for (int i = 0; i < value.length; i++) {
      dateNumber = dateNumber + value[i];
    }
    final ticketnumber = postSeq.toString() + dateNumber + curtainId.toString();
    return ticketnumber;
  }

  // 주문번호 만드는 함수
  String makeOrderNo({
  required int postSeq,
  required String postCreateDate, // "2026-01-21"
}) {
  // 날짜 YYYYMMDD
  final date = postCreateDate.replaceAll('-', '');

  // seq 6자리 0패딩
  final seq = postSeq.toString().padLeft(6, '0');

  return 'CM$date-$seq';
}


}
final orderProviderAsync = AsyncNotifierProvider<OrderNotifier,void>(
  OrderNotifier.new
);