import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentState {
  final int? selectedMode; 
  final DateTime? selectedDate;
  final String? selectedTime;
  final String? selectedGrade; 
  final String? selectedRow;   
  final int quantity;

  PaymentState({
    this.selectedMode,
    this.selectedDate,
    this.selectedTime,
    this.selectedGrade,
    this.selectedRow,
    this.quantity = 1,
  });

  PaymentState copyWith({
    int? selectedMode,
    DateTime? selectedDate,
    String? selectedTime,
    String? selectedGrade,
    String? selectedRow,
    int? quantity,
  }) {
    return PaymentState(
      selectedMode: selectedMode ?? this.selectedMode,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedGrade: selectedGrade ?? this.selectedGrade,
      selectedRow: selectedRow ?? this.selectedRow,
      quantity: quantity ?? this.quantity,
    );
  }
}

class PaymentNotifier extends Notifier<PaymentState> {
  @override
  PaymentState build() => PaymentState();

  void setMode(int mode) {
    state = PaymentState(selectedMode: mode); 
  }

  void setDate(DateTime date) {
    state = state.copyWith(selectedDate: date, selectedTime: null, selectedGrade: null, selectedRow: null);
  }

  void setTime(String time) {
    state = state.copyWith(selectedTime: time, selectedGrade: null, selectedRow: null);
  }

  void setGrade(String gradeBit) {
    state = state.copyWith(selectedGrade: gradeBit, selectedRow: null);
  }

  void setRow(String rowName) {
    state = state.copyWith(selectedRow: rowName);
  }

  void setQuantity(int q) {
    if (q >= 1 && q <= 10) state = state.copyWith(quantity: q);
  }
}

final paymentProvider = NotifierProvider<PaymentNotifier, PaymentState>(PaymentNotifier.new);