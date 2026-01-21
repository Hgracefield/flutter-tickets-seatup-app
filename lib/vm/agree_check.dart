import 'package:flutter_riverpod/flutter_riverpod.dart';

class AgreeState{
  final bool agreeNotice;
  final bool agreeRefund;

  AgreeState(
    {
      this.agreeNotice = false,
      this.agreeRefund = false
    }
  );


  AgreeState copywith(
    {
      bool? agreeNotice,
      bool? agreeRefund
    }
  ){
    return AgreeState(
      agreeNotice: agreeNotice ?? this.agreeNotice,
      agreeRefund: agreeRefund ?? this.agreeRefund
    );
  }
}

class AgreeCheck extends Notifier<AgreeState> {
  @override
  AgreeState build() => AgreeState();

  void agreeChangeNotice(bool value){
    state = state.copywith(
      agreeNotice: value
    );
  }

  void agreeChangeRefund(bool value){
    state = state.copywith(
      agreeRefund: value
    );
  }
}
final agreeNotifier = NotifierProvider<AgreeCheck,AgreeState>(
  AgreeCheck.new
);