import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

enum TicketCategory {
  musical,
  concert,
  play,
  classic,
  sports,
  leisure,
  expo,
  kids,
  topping,
  benefit,
}

// 현재 선택된 카테고리 상태
final selectedCategoryProvider = StateProvider<TicketCategory?>(
  (ref) => null,
);
