import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/util/message.dart';
import 'package:seatup_app/view/app_route/app_route.dart';
// import 'package:http/http.dart' as http;
import 'package:seatup_app/vm/user_notifier.dart';
import 'package:seatup_app/util/login_status.dart';

class UserLogin extends ConsumerStatefulWidget {
  const UserLogin({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserLoginState();
}

class _UserLoginState extends ConsumerState<UserLogin> {
  // === Property ===
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late bool showPassword; // 비밀번호 숨김 on/off 토글

  Message message = Message(); // util Message 기능 사용

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    showPassword = true;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image.asset(
                  //   'images/logo.png',
                  //   width: 100,
                  // ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Seat Up !!',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  _buildTextEditingField(
                    '이메일',
                    emailController,
                    Icon(Icons.email, color: Colors.grey),
                    'email@example.com',
                    false,
                  ),
                  _buildTextEditingField(
                    '비밀번호',
                    passwordController,
                    Icon(Icons.lock, color: Colors.grey),
                    'password',
                    true,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 40, 0, 30),
                    child: ElevatedButton(
                      onPressed: () => checkLogin(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(16),
                        ),
                        minimumSize: Size(MediaQuery.widthOf(context), 55),
                      ),
                      child: Text(
                        '로그인',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(thickness: 1, color: Colors.grey[300]),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          '처음이신가요?',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(thickness: 1, color: Colors.grey[300]),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoute.signUp).then((value) {
                        emailController.clear();
                        passwordController.clear();
                      },);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '회원가입하기',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.arrow_forward_outlined, color: Colors.black),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  } // build

  // ==== Widgets ====

  Widget _buildTextEditingField(
    String title,
    TextEditingController controller,
    Icon icon,
    String hint,
    bool showSuffix,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        TextField(
          controller: controller,
          obscureText: showSuffix ? showPassword: false,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,

            ),
            prefixIcon: icon,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[200],
            suffixIcon: showSuffix
                ? IconButton(
                    icon: Icon(
                      showPassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      showPassword = !showPassword;
                      setState(() {});
                    },
                  )
                : null
          ),
        ),
      ],
    );
  }

  // --- Functios ---
  void checkLogin() {
    if (emailController.text.trim().isEmpty) {
      // 이메일이 비어있을 경우 -> SnackBar 처리
      message.errorSnackBar(context, '이메일을 입력하세요.');
    } else if (passwordController.text.trim().isEmpty) {
      // 비밀번호가 비어있을 경우 -> SnackBar 처리
      message.errorSnackBar(context, '비밀번호를 입력하세요.');
    } else {
      userLogin();
    }
  }

  Future<void> userLogin() async {
    final userNotifier = ref.read(userNotifierProvider.notifier);
    final user = await userNotifier.loginData(
      emailController.text.trim(),
      passwordController.text.trim(),
    ); // get storage 부분
    var result = await userNotifier.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    switch (result) {
      case LoginStatus.success:
        message.successSnackBar(context, '로그인 성공');
        await userNotifier.saveUserLogin(
          user.first,
        ); // get storage저장하는곳
        Navigator.pushNamed(context, AppRoute.main).then((value) {
          emailController.clear();
          passwordController.clear();
        });
        break;
      case LoginStatus.fail:
        message.errorSnackBar(context, '로그인 실패');
        break;
      case LoginStatus.withdraw:
        message.errorSnackBar(context, '탈퇴한 회원입니다.');
        break;
    }
  }

} // class
