import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart'; // 1. 날짜 데이터 초기화를 위한 임포트 추가
// import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:seatup_app/firebase_options.dart';
import 'package:seatup_app/view/app_route/app_route.dart';
import 'package:seatup_app/view/app_route/app_router.dart';
import 'package:seatup_app/view/app_route/router_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. 한국어(ko_KR) 로케일 데이터 초기화 추가
  await initializeDateFormatting('ko_KR', null);
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init();
  // KakaoSdk.init(nativeAppKey: '6a4ed9946737798d62126a14547f4c74');
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SeatUp App',
      debugShowCheckedModeBanner: false,
      // theme 부분 seedColor 수정 (기존 코드의 .fromSeed 오타 교정)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      onGenerateRoute: AppRouter.generate,
      showSemanticsDebugger: false,
      home: const RouterPage(), 
    );
  }
}