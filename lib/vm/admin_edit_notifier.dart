import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminEditNotifier extends Notifier<void> {
  @override
  void build() {
  }

  Future<String> pickDate(BuildContext context) async {
    final now = DateTime.now();
    String value = '';

    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
      initialDate: now,
    );

    if (picked == null) {return'';}
      final y = picked.year.toString();
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
 
    

    return '$y-$m-$d';
  }

  Future<String> pickTime(BuildContext context) async {
    String value = '';

    final t = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 14, minute: 0),
    );

    if (t == null) {return '';}
      final hh = t.hour.toString().padLeft(2, '0');
      final mm = t.minute.toString().padLeft(2, '0');

    return '$hh:$mm';
  }
}

final adminEditNotifierProvider =
      NotifierProvider<AdminEditNotifier, void>(
  AdminEditNotifier.new,
);
