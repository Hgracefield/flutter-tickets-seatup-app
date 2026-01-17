import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:seatup_app/util/message.dart';
import 'package:seatup_app/view/app_route/app_route.dart';
import 'package:http/http.dart' as http;

class UserLogin extends StatefulWidget {
  const UserLogin({super.key});

  @override
  State<UserLogin> createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  // Property
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
                      Navigator.pushNamed(context, AppRoute.signUp);
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
                  // TextButton(
                  //   onPressed: () {_signIn();},
                  //   child: Row(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       Text(
                  //         '구글 로그인',
                  //         style: TextStyle(
                  //           color: Colors.black,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //       Icon(Icons.arrow_forward_outlined, color: Colors.black),
                  //     ],
                  //   ),
                  // ),
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
                : Center(),
          ),
        ),
      ],
    );
  }

  // --- Functios ---
  void checkLogin() {
    if (emailController.text.trim().isEmpty) {
      // 이메일이 비어있을 경우 -> SnackBar 처리
      message.errorSnackBar('Error', '이메일을 입력하세요.');
    } else if (passwordController.text.trim().isEmpty) {
      // 비밀번호가 비어있을 경우 -> SnackBar 처리
      message.errorSnackBar('Error', '비밀번호를 입력하세요.');
    } else {
      customerLogin();
    }
  }

  Future<void> customerLogin() async {
    var url = Uri.parse("127.0.0.1/customer/login");
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        // 백엔드 서버로 로그인 데이터 전송
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
      }),
    );

    var jsonData = json.decode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      // GlobalData.customerId = jsonData['id'];
      // 로그인 성공 -> MainPage 이동
      Navigator.pushNamed(context, AppRoute.userMypage);
    } else {
      // 로그인 실패 -> errorSnackBar 출력
      message.errorSnackBar('Error', jsonData['detail']);
    }
  }

  
} // class
