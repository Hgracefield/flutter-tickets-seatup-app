import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/view/app_route/app_route.dart';
import 'package:seatup_app/view/app_route/app_router.dart';
import 'package:seatup_app/view/app_route/main_page.dart';

void main() {
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
      initialRoute: AppRoute.main,
      // onGenerateRoute: AppRouter.generate,
      home: const MainPage(), // 추후 삭제 연결
    );
  }
}
