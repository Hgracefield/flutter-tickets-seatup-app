import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurtainManagerNotifier extends  Notifier <CurtainManagerState>{
  @override
  CurtainManagerState build() => CurtainManagerState();


  void setType(int id) => state = state.copyWith(typeIndex: id);
  void setTitle(int id) => state = state.copyWith(titleIndex: id);
  void setPlace(int id) => state = state.copyWith(placeIndex: id);
  void setGrade(int id) => state = state.copyWith(gradeMask: id);
  void setArea(int id) => state = state.copyWith(areaMask: id);


  void toggleGrade(int bit, bool checked)
  {
    final next = checked
    ? (state.selectedGradeMask! | bit)
    : (state.selectedGradeMask! & ~bit);
    state = state.copyWith(gradeMask: next);
  }

  void toggleArea(int bit, bool checked)
  {
    final next = checked
    ? (state.selectedAreaMask! | bit)
    : (state.selectedAreaMask! & ~bit);
    state = state.copyWith(areaMask: next);
  }

  void reset()
  {
    state = CurtainManagerState();
  }
}

final curtainManagerNotifier = NotifierProvider<CurtainManagerNotifier, CurtainManagerState>(
  CurtainManagerNotifier.new
);

class CurtainManagerState
{
  int? selectedTypeIndex;
  int? selectedTitleIndex;
  int? selectedPlaceIndex;
  int? selectedGradeMask;
  int? selectedAreaMask;

  CurtainManagerState({
    this.selectedTitleIndex = 0,
    this.selectedTypeIndex = 0,
    this.selectedPlaceIndex = 0,
    this.selectedGradeMask = 0,
    this.selectedAreaMask = 0
  });

  CurtainManagerState copyWith({int? typeIndex, 
  int? titleIndex, int? gradeMask, int? areaMask, int? placeIndex}) =>
  CurtainManagerState(
    selectedGradeMask: gradeMask ?? this.selectedGradeMask,
    selectedTitleIndex: titleIndex?? this.selectedTitleIndex,
    selectedAreaMask: areaMask ?? this.selectedAreaMask,
    selectedTypeIndex: typeIndex ?? this.selectedTypeIndex ,
    selectedPlaceIndex: placeIndex ?? this.selectedPlaceIndex
  );
}