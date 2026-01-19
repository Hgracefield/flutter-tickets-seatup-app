import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/view/admin/admin_dashboard.dart';
import 'package:seatup_app/vm/staff_provider.dart';

class AdminLogin extends ConsumerStatefulWidget {
  const AdminLogin({super.key});

  @override
  ConsumerState<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends ConsumerState<AdminLogin> {
  final TextEditingController staffIdController = TextEditingController();
  final TextEditingController staffpwdController = TextEditingController();

  @override
  void dispose() {
    staffIdController.dispose();
    staffpwdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4',
                  fit: BoxFit.cover,
                  height: double.infinity,
                ),
                Container(color: Colors.black.withAlpha(120)),
                Positioned(
                  bottom: 40,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildText(
                        'Seat Up',
                        fontsize: 30,
                        color: Color.fromARGB(201, 255, 255, 255),
                        fontWeight: FontWeight.w700,
                      ),
                      _buildText(
                        '티켓 거래 현황 관리 접속',
                        fontsize:  18,
                        color:  Color.fromARGB(201, 255, 255, 255),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(50, 150, 50, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildText('관리자 로그인',fontsize:  40,color:  Colors.black),
                  _buildText('환영합니다. 로그인 해주세요.',fontsize:  30,color:  Colors.black),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 5),
                    child: _buildText('관리자 아이디',fontsize:  16, color:  Colors.black),
                  ),
                  _buildTextfield(staffIdController, 'abc@gmail.com'),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                    child: _buildText('관리자 비밀번호', fontsize:  16, color:  Colors.black),
                  ),
                  _buildTextfield(staffpwdController, 'Enter your password',obscureText: true , showCursor: false),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(3),
                          ),
                        ),
                        onPressed: () => staffLogin(),
                        child: _buildText('로그인',fontsize: 20,color: Colors.white)
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  } // build

  //--------------------------------------Widget--------------------------------------
  Widget _buildText(
    String label, {
    FontWeight fontWeight = FontWeight.normal,
    double fontsize = 14,
    Color color = Colors.black
  }) {
    return Text(
      label,
      style: TextStyle(
        fontSize: fontsize,
        color: color,
        fontWeight: fontWeight,
      ),
    );
  }

  Widget _buildTextfield(
    TextEditingController controller, 
    String hinttext, 
    {bool obscureText  = false , String obscuringCharacter = '●', bool showCursor = true}
  ) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      obscuringCharacter: obscuringCharacter,
      showCursor: showCursor,
      decoration: InputDecoration(
        hintText: hinttext,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: BorderSide(color: Colors.black, width: 1),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: Colors.red),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
  // ---------------------------------- Functions --------------------------------
  Future<void> staffLogin() async{
    final id = staffIdController.text.trim();
    final pwd = staffpwdController.text.trim();

    if (id.isEmpty || pwd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('아이디, 패스워드를 다시 입력해주세요'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.red,
      ),
    );
      return;
    }
    final result = await ref.read(staffNotifierProvider.notifier).loginCheckStaff(id, pwd);

    if (!mounted) return;

    if (result.isNotEmpty) {
      final staff = result.first;
      ref.read(staffNotifierProvider.notifier).saveLogin(staff);
      Navigator.push(context, MaterialPageRoute(builder: (context) => AdminDashboard(),));
    }else{
       ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.red,
      ),
    );
    }
  }
} // class
