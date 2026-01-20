import 'package:flutter_riverpod/flutter_riverpod.dart';

class SellRegisterNotifier extends Notifier<SellRegisterState>{
  @override
  SellRegisterState build() => SellRegisterState();

  void setCurtain(int id) => state = state.copyWith(curtainIndex: id);
  void setGrade(int id)   => state = state.copyWith(gradeIndex: id);
  void setArea(int id)    => state = state.copyWith(areaIndex: id);
}

final sellRegisterNotifier = NotifierProvider<SellRegisterNotifier, SellRegisterState>(
  SellRegisterNotifier.new
);

class SellRegisterState
{
  int? selectCurtainIndex;
  int? selectGradeIndex;
  int? selectAreaIndex;

  SellRegisterState({
    this.selectCurtainIndex = -1,
    this.selectGradeIndex = -1,
    this.selectAreaIndex = -1
  });

  SellRegisterState copyWith({int? curtainIndex, int? gradeIndex, int? areaIndex}) =>
  SellRegisterState(
    selectCurtainIndex: curtainIndex?? this.selectCurtainIndex,
    selectGradeIndex: gradeIndex ?? this.selectGradeIndex,
    selectAreaIndex: areaIndex ?? this.selectAreaIndex 
  );
}