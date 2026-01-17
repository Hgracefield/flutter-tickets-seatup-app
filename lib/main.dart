import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:seatup_app/firebase_options.dart';
import 'package:seatup_app/view/app_route/app_route.dart';
import 'package:seatup_app/view/app_route/app_router.dart';
import 'package:seatup_app/view/app_route/router_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init();
   KakaoSdk.init(nativeAppKey: '6a4ed9946737798d62126a14547f4c74');
  

  // KakaoSdk.init(nativeAppKey: '네이티브_앱_키');
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      // initialRoute: AppRoute.main,
      onGenerateRoute: AppRouter.generate,
      showSemanticsDebugger: false,
      home: RouterPage(), // 추후 삭제 연결
    );
  }
}
