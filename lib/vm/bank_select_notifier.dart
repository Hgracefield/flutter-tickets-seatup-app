import 'package:flutter_riverpod/flutter_riverpod.dart';

class BankSelectNotifier extends Notifier<BankSelectState>{
  @override
  BankSelectState build()=> BankSelectState();

  void setBank(String name) => state = state.copyWith(bank: name);
}

final bankSelectNotifier = NotifierProvider<BankSelectNotifier,BankSelectState>(
BankSelectNotifier.new
);

class BankSelectState{
  String? bank = "";
  BankSelectState({this.bank});
  BankSelectState copyWith({String? bank})=>BankSelectState(bank: bank);
}
