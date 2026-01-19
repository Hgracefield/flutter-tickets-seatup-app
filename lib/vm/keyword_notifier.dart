import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/vm/keyword_handler.dart';

class KeywordNotifier extends AsyncNotifier<List<String>>{
  final KeywordHandler _dbHandler = KeywordHandler();
  
  @override
  Future<List<String>> build() async =>_dbHandler.queryKeyword(); 


  Future loadKeyword() async{
    state = AsyncLoading();
    state = await AsyncValue.guard(() => _dbHandler.queryKeyword());
  }

  Future<int> existKeyword(String word) async{
    return await _dbHandler.existKeyword(word);
  }

  Future insertKeyword(String word) async{
    await _dbHandler.insertKeyword(word);
    await loadKeyword();
  }

  Future updateKeyword(String word) async
  {
    await _dbHandler.updateKeyword(word);
    await loadKeyword();    
  }
}
final keywordHandlerNotifilerProvider = AsyncNotifierProvider<KeywordNotifier, List<String>>(
  KeywordNotifier.new
);