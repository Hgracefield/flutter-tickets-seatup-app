import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:seatup_app/view/app_route/app_route.dart';

class UserLoginSelectPage extends StatelessWidget {
  const UserLoginSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
            ),

            // _buildButton('카카오로 로그인',Colors.yellow, Colors.black, (){_kakaoLogin();}, context),
            _buildButton('구글로 로그인',Colors.blueAccent, Colors.white, _googleLogIn, context),
            _buildButton('이메일로 로그인',Colors.black, Colors.white, (){
              moveUserLogin(context);
            }, context),
          ],
        ),
      ),
    );
  } // build

  // === Widget ===

  Widget _buildButton(String str, Color backColor, Color foreColor, VoidCallback func, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 40, 0, 30),
      child: ElevatedButton(
        onPressed:  func,
        style: ElevatedButton.styleFrom(
          backgroundColor: backColor,
          foregroundColor: foreColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(16),
          ),
          minimumSize: Size(MediaQuery.widthOf(context), 55),
        ),
        child: Text(str, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  } // _buildButton

  // === Functions ===

  

  Future<void> _googleLogIn() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return; // 취소

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  void moveUserLogin(BuildContext context)
  {
    Navigator.pushNamed(context, AppRoute.userLogin);
  }

// Future<void> _kakaoLogin() async {
//     // 앱 재실행 시 토큰이 남아있으면 "로그인된 것처럼" 보이게 처리
//     // (토큰 유효성까지 확인하려면 accessTokenInfo() 호출)
//     final tokenManager = TokenManagerProvider .instance.manager;
//     final hasToken = await tokenManager.getToken() != null;

//     // setState(() {
//     //   _isLoggedIn = hasToken;
//     //   _status = hasToken ? 'Token exists (maybe logged in)' : 'No token';
//     // });

//     if (hasToken) {
//       await _fetchMe(); // 프로필 조회 시도
//     }
//   }

  // Future<void> _kakaoLogin() async {
  //   try {
  //     // setState(() => _status = 'Logging in...');
  //     print('Logging in ...');
  //     final installed = await isKakaoTalkInstalled();
  //     if (installed) {
  //       await UserApi.instance.loginWithKakaoTalk();
  //     } else {
  //       await UserApi.instance.loginWithKakaoAccount();
  //     }

  //     print('Logging Success');
  //     // setState(() {
  //     //   _isLoggedIn = true;
  //     //   _status = 'Login success';
  //     // });

  //     await _fetchMe();
  //   } catch (e) {
  //     // setState(() {
  //     //   _isLoggedIn = false;
  //     //   _status = 'Login failed: $e';
  //     // });
  //   }
  // }

  // Future<void> _fetchMe() async {
  //   try {
  //     final user = await UserApi.instance.me();

  //     // setState(() {
  //     //   _userId = user.id?.toString() ?? '-';
  //     //   _nickname = user.kakaoAccount?.profile?.nickname ?? '-';
  //     //   _status = 'Fetched user profile';
  //     // });
  //     print('${user.id.toString()} / ${user.kakaoAccount?.profile?.nickname}' );
  //   } catch (e) {
  //     // setState(() => _status = 'Fetch profile failed: $e');
  //   }
  // }

  // Future<void> _logout() async {
  //   try {
  //     await UserApi.instance.logout();
  //     // setState(() {
  //     //   _isLoggedIn = false;
  //     //   _userId = '-';
  //     //   _nickname = '-';
  //     //   _status = 'Logged out';
  //     // });
  //   } catch (e) {
  //     // setState(() => _status = 'Logout failed: $e');
  //   }
  // }

  // Future<void> _unlink() async {
  //   try {
  //     await UserApi.instance.unlink(); // 카카오 계정과 앱 연결 끊기
  //     // setState(() {
  //     //   _isLoggedIn = false;
  //     //   _userId = '-';
  //     //   _nickname = '-';
  //     //   _status = 'Unlinked (disconnected)';
  //     // });
  //   } catch (e) {
  //     // setState(() => _status = 'Unlink failed: $e');
  //   }
  // }

  // Future<void> _checkToken() async {
  //   try {
  //     final info = await UserApi.instance.accessTokenInfo();
  //     // setState(() => _status = 'Token valid. Expires in: ${info.expiresIn}s');
  //   } catch (e) {
  //     // setState(() => _status = 'Token check failed (need login): $e');
  //   }
  // }

  // @override
  // Widget build(BuildContext context) {
  //   final buttons = _isLoggedIn
  //       ? [
  //           ElevatedButton(
  //             onPressed: _fetchMe,
  //             child: const Text('내 정보 조회(me)'),
  //           ),
  //           ElevatedButton(
  //             onPressed: _checkToken,
  //             child: const Text('토큰 유효성 확인'),
  //           ),
  //           ElevatedButton(
  //             onPressed: _logout,
  //             child: const Text('로그아웃'),
  //           ),
  //           OutlinedButton(
  //             onPressed: _unlink,
  //             child: const Text('연결 끊기(unlink)'),
  //           ),
  //         ]
  //       : [
  //           ElevatedButton(
  //             onPressed: _login,
  //             child: const Text('카카오 로그인'),
  //           ),
  //         ];

  //   return Scaffold(
  //     appBar: AppBar(title: const Text('Kakao Login Demo')),
  //     body: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text('Status: $_status'),
  //           const SizedBox(height: 12),
  //           Text('UserId: $_userId'),
  //           Text('Nickname: $_nickname'),
  //           const SizedBox(height: 20),
  //           ...buttons.map((b) => Padding(
  //                 padding: const EdgeInsets.only(bottom: 8),
  //                 child: SizedBox(width: double.infinity, child: b),
  //               )),
  //         ],
  //       ),
  //     ),
  //   );
  // }
} // class
