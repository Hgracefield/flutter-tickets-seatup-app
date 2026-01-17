import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

            _buildButton('카카오로 로그인',Colors.yellow, Colors.black, _kakaoLogin, context),
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

  Widget _buildButton(String str, Color backColor, Color foreColor, Function func, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 40, 0, 30),
      child: ElevatedButton(
        onPressed: () => func,
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

  Future _kakaoLogin() async{

  }

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

  Future<void> _signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }

  void moveUserLogin(BuildContext context)
  {
    Navigator.pushNamed(context, AppRoute.userLogin);
  }

} // class
