import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TicketCategory {
  play,
  musical,
  concert,
  classic,
  expo,
  sports,
  leisure,
  kids,
  topping,
  benefit,
}

class CategoryFilterState {
  final TicketCategory? category;
  final int? typeSeq;

  const CategoryFilterState({this.category, this.typeSeq});

  static const Object _sentinel = Object();

  CategoryFilterState copyWith({
    TicketCategory? category,
    Object? typeSeq = _sentinel,
  }) {
    return CategoryFilterState(
      category: category ?? this.category,
      typeSeq: typeSeq == _sentinel ? this.typeSeq : typeSeq as int?,
    );
  }
}

class CategoryFilterNotifier extends Notifier<CategoryFilterState> {
  @override
  CategoryFilterState build() => const CategoryFilterState(category:TicketCategory.musical, typeSeq: 2);

  void select({
    required TicketCategory category,
    required int? typeSeq,
  }) {
    state = state.copyWith(category: category, typeSeq: typeSeq);
  }

  void clear() {
    state = const CategoryFilterState();
  }
}

final categoryFilterProvider =
    NotifierProvider<CategoryFilterNotifier, CategoryFilterState>(
      CategoryFilterNotifier.new,
    );
