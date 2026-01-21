import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:seatup_app/util/message.dart';
import 'package:seatup_app/view/app_route/app_route.dart';
import 'package:seatup_app/view/user/sign_up.dart';
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SignUp(email: '', name: '', phone: ''),
                        ),
                      ).then((value) {
                        emailController.clear();
                        passwordController.clear();
                      });
                      // Navigator.pushNamed(context, AppRoute.signUp).then((
                      //   value,
                      // ) {
                      //   emailController.clear();
                      //   passwordController.clear();
                      // });
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
                  TextButton(
                    onPressed: () {
                      _googleLogIn();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '구글로 시작하기',
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
          obscureText: showSuffix ? showPassword : false,
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
                : null,
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
    final users = await userNotifier.loginData(
      emailController.text.trim(),
      passwordController.text.trim(),
    ); // get storage 부분
    // var result = await userNotifier.login(
    //   emailController.text.trim(),
    //   passwordController.text.trim(),
    // );

    decideLoginProcuess(users);
    // if(user != [])
    // {
    //   if(user.first['user_withdraw_date'] == null)
    //   {
    //     message.successSnackBar(context, '로그인 성공');
    //     await userNotifier.saveUserLogin(user.first); // get storage저장하는곳
    //     Navigator.pushNamed(context, AppRoute.main).then((value) {
    //       emailController.clear();
    //       passwordController.clear();
    //     });
    //   }
    //   else
    //   { 
    //     message.errorSnackBar(context, '탈퇴한 회원입니다.');
    //   }
    // }
    // else
    // {
    //   message.errorSnackBar(context, '로그인 실패');
    // }
  }

  Future<void> _googleLogIn() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return; // 취소

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final result = await FirebaseAuth.instance.signInWithCredential(credential);

    final user = await ref.read(userNotifierProvider.notifier).existUser(result.user!.email!);

    if(!mounted) return;

    if(user == 0)
    {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignUp(email: result.user!.email!, name: result.user!.displayName ?? '', phone: result.user!.phoneNumber ?? ''),
        ),
      ).then((value) {
        emailController.clear();
        passwordController.clear();
      });
    }
    else
    {
      final users = await ref.read(userNotifierProvider.notifier).googleLoginData(result.user!.email!);
      
      
      decideLoginProcuess(users);
      // message.successSnackBar(context, '로그인 성공');
      //   // await ref.read(userNotifierProvider.notifier).saveUserLogin(); // get storage저장하는곳
      //   Navigator.pushNamed(context, AppRoute.main).then((value) {
      //     emailController.clear();
      //     passwordController.clear();
      //   });
    }
  }

  void decideLoginProcuess(List<dynamic> users) async
  {
    if(!mounted) return;

    if(users.length > 0)
    {
      if(users.first['user_withdraw_date'] == null)
      {
        message.successSnackBar(context, '로그인 성공');
        await ref.read(userNotifierProvider.notifier).saveUserLogin(users.first); // get storage저장하는곳
        Navigator.pushNamed(context, AppRoute.main).then((value) {
          emailController.clear();
          passwordController.clear();
        });
      }
      else
      { 
        message.errorSnackBar(context, '탈퇴한 회원입니다.');
      }
    }
    else
    {
      message.errorSnackBar(context, '로그인 실패');
    }
  }
} // class
