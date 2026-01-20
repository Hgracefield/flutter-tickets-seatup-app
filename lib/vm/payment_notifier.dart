import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentState {
  final int? selectedMode; 
  final DateTime? selectedDate;
  final String? selectedTime;
  final String? selectedRow;
  final int quantity;
  final bool isPriceOver;

  PaymentState({
    this.selectedMode,
    this.selectedDate,
    this.selectedTime,
    this.selectedRow,
    this.quantity = 1,
    this.isPriceOver = false,
  });

  PaymentState copyWith({
    int? selectedMode,
    DateTime? selectedDate,
    String? selectedTime,
    String? selectedRow,
    int? quantity,
    bool? isPriceOver,
  }) {
    return PaymentState(
      selectedMode: selectedMode ?? this.selectedMode,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedRow: selectedRow ?? this.selectedRow,
      quantity: quantity ?? this.quantity,
      isPriceOver: isPriceOver ?? this.isPriceOver,
    );
  }
}

class PaymentNotifier extends Notifier<PaymentState> {
  
  @override
  PaymentState build() {
    return PaymentState();
  }

  void setMode(int mode) {
    state = PaymentState(selectedMode: mode);
  }

  void setDate(DateTime date) {
    state = state.copyWith(selectedDate: date, selectedTime: null, selectedRow: null);
  }

  void setTime(String time) {
    state = state.copyWith(selectedTime: time, selectedRow: null);
  }

  void setRow(String row) {
    state = state.copyWith(selectedRow: row);
  }

  void setQuantity(int q) {
    if (q >= 1 && q <= 10) {
      state = state.copyWith(quantity: q);
    }
  }

  void setPriceStatus(bool isOver) {
    state = state.copyWith(isPriceOver: isOver);
  }
}

final paymentProvider = NotifierProvider<PaymentNotifier, PaymentState>(
  PaymentNotifier.new,
);