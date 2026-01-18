import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/user.dart';
import 'package:seatup_app/util/message.dart';
import 'package:seatup_app/vm/user_notifier.dart';

// ignore: must_be_immutable
class UserInfoUpdate extends ConsumerStatefulWidget {
  const UserInfoUpdate({super.key});

  @override
  ConsumerState<UserInfoUpdate> createState() => _UserInfoUpdateState();
}

class _UserInfoUpdateState extends ConsumerState<UserInfoUpdate> {
  // === Property ===
  late String _email; // 이메일은 변경 불가

  // 컨트롤러 선언
  late TextEditingController emailController;
  // late TextEditingController passwordController;
  // late TextEditingController confirmPasswordController;
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController bankController;
  late TextEditingController accountController;

  Message message = Message();

  User? _user; // 서버에서 받아온 정보를 담을 변수

    final passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$',
  );
  final phoneRegex = RegExp(r'^01[016789]-\d{3,4}-\d{4}$');
  final accountRegex = RegExp(r'^(\d{1,})(-(\d{1,})){1,}');
  
  @override
  void initState() async{
    super.initState();
    _user = await ref.read(userNotifierProvider.notifier).fetchUser();
    emailController = TextEditingController(text: _user!.user_email);
    nameController = TextEditingController(text: _user!.user_name);
    phoneController = TextEditingController(text: _user!.user_phone);
    addressController = TextEditingController(text: _user!.user_address);
    bankController = TextEditingController(text: _user!.user_bank_name);
    accountController = TextEditingController(text: _user!.user_account);
  }

  @override
  void dispose() {
    emailController.dispose();
    // passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  // // 회원 정보 수정
  // Future<void> _updateProfile() async{
  //   try{
  //     final customer = Customer(
  //       customer_email: _email,
  //       customer_password: _newPasswordController.text.trim(),
  //       customer_name: _nameController.text.trim(),
  //       customer_phone: _phoneController.text.trim(),
  //       customer_address: "N/A"
  //     );
  //     final url = Uri.parse("${GlobalData.url}/customer/update/${GlobalData.customerId}");
  //     final response = await http.post(
  //       url,
  //       headers: {'Content-Type' : 'application/json'},
  //       body: json.encode(customer.toJson()),
  //     );
  //     final data = json.decode(utf8.decode(response.bodyBytes));
  //     final result = data['results'];
      

  //     final newPassword = _newPasswordController.text.trim();
  //     final confirmPassword = _confirmPasswordController.text.trim();

  //     if(result == 'OK'){
  //       message.showDialog('Success', '회원 정보가 수정되었습니다.');
  //     }else if(newPassword.isNotEmpty && newPassword != confirmPassword){ // 비밀번호 유효성 검사
  //       message.errorSnackBar('Error', '새 비밀번호가 일치하지 않습니다.');
  //     }else{
  //       message.errorSnackBar('Error', '회원 정보 수정에 실패했습니다.');
  //     }
  //   } catch(e){
  //     message.errorSnackBar('Error', '회원 정보 수정에 실패했습니다.');
  //   }
  // }

  // // 회원 탈퇴
  // Future<void> _withdrawUser() async{
  //   try{
  //     final customer = Customer(
  //       customer_email: _email,
  //       customer_password: _newPasswordController.text.trim(),
  //       customer_name: _nameController.text.trim(),
  //       customer_phone: _phoneController.text.trim(),
  //       customer_address: "N/A"
  //     );
  //     final url = Uri.parse("${GlobalData.url}/customer/delete/${GlobalData.customerId}");
  //     final response = await http.post(
  //       url,
  //       headers: {'Content-Type' : 'application/json'},
  //       body: json.encode(customer.toJson()),
  //     );
  //     final data = json.decode(utf8.decode(response.bodyBytes));
  //     final result = data['results'];
      
  //     if(result == 'OK'){
  //       message.showDialog('Success', '회원 탈퇴가 완료되었습니다.');
  //     }else{
  //       message.errorSnackBar('Error', '회원 탈퇴에 실패했습니다.');
  //     }
  //   } catch(e){
  //     message.errorSnackBar('Error', '회원 탈퇴에 실패했습니다.');
  //   }
  // }

  

  @override
  Widget build(BuildContext context) {
    // final userNotifier = ref.read(userNotifierProvider.notifier);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: const Column(
            children: [
              // Text('On & Tap', style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
              // Text('회원 정보 수정', style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 이름 필드
              _buildInputSection(
                label: '이름',
                controller: nameController,
                hintText: '이름을 입력하세요.',
              ),
      
              // 2. 전화번호 필드
              _buildInputSection(
                label: '전화번호',
                controller: phoneController,
                hintText: '전화번호를 입력하세요.',
              ),
      
              // 3. 이메일 필드 (변경 불가)
              _buildInputSection(
                label: '이메일',
                controller: TextEditingController(text: _email),
                readOnly: true,
                hintText: ' ',
              ),
      
              // // 4. 비밀번호 변경 제목
              // const Text('비밀번호 변경', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              // // const SizedBox(height: 8),
      
              // // 5. 새 비밀번호
              // _buildInputSection(
              //   label: '', // 레이블 숨김
              //   controller: _newPasswordController,
              //   hintText: '새 비밀번호를 입력하세요.',
              //   isPassword: true,
              // ),
      
              // // 6. 새 비밀번호 확인 (위젯 간결화를 위해 SizedBox를 15 -> 0으로 설정 후 직접 간격 조정)
              // Padding(
              //   padding: const EdgeInsets.only(bottom: 40.0),
              //   child: _buildInputSection(
              //     label: '', // 레이블 숨김
              //     controller: _confirmPasswordController,
              //     hintText: '새 비밀번호 확인을 입력하세요.',
              //     isPassword: true,
              //   ),
              // ),
              
              // 7. 버튼 영역 (정보 저장 및 탈퇴하기)
              Row(
                children: [
                  // 탈퇴하기 버튼
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('탈퇴하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // 정보 저장 버튼
                  Expanded(
                    child: ElevatedButton(
                      onPressed:() async {
                        User user = User(
                        user_email: emailController.text.trim(), 
                        user_password: _user!.user_password, 
                        user_name: nameController.text.trim(), 
                        user_phone: phoneController.text.trim(), 
                        user_address: addressController.text.trim(), 
                        user_signup_date: _user!.user_signup_date, 
                        user_account: accountController.text.trim(), 
                        user_bank_name: bankController.text.trim(), 
                        user_withdraw_date: "");
                        
                        final result = await ref.read(userNotifierProvider.notifier).updateUser(user);
                          
                        if(result == 'OK'){
                            message.showDialog('회원 정보 수정 성공', '회원 정보가 수정되었습니다.', []);
                          // }else if(newPassword.isNotEmpty && newPassword != confirmPassword){ // 비밀번호 유효성 검사
                          //   message.errorSnackBar(context, '새 비밀번호가 일치하지 않습니다.');
                          }else{
                            message.errorSnackBar(context, '회원 정보 수정에 실패했습니다.');
                          }
                          message.errorSnackBar(context, '회원 정보 수정에 실패했습니다.');
                        
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text(
                        '정보 저장',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  } // build

  // === Widgets === 

  Widget _buildInputSection({
    required String label,
    required TextEditingController controller,
    String? hintText,
    bool readOnly = false,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!hintText.isNullOrEmpty) 
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),

        Container(
          height: 50,
          decoration: BoxDecoration(
            color: readOnly ? Colors.grey[100] : Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            obscureText: isPassword,
            keyboardType: label == '전화번호' && !readOnly ? TextInputType.phone : TextInputType.text,
            style: TextStyle(color: readOnly ? Colors.grey[700] : Colors.black),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: hintText,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
              border: InputBorder.none,
              // 이메일 필드에만 잠금 아이콘 표시
              suffixIcon: Padding(
                // 텍스트 가운데 정렬을 위해 suffixIcon padding 조절
                padding: const EdgeInsets.only(right: 10),
                child: label == '이메일' && readOnly 
                    ? const Icon(Icons.lock_outline, color: Colors.grey) 
                    : null,
              ),
            ),
          ),
        ),
        // SizedBox(height: hintText.isNullOrEmpty ? 15 : 20),
      ],
    );
  }
} // class

// 힌트 텍스트가 비어있는지 확인하는 확장 함수 (간결한 코드 작성을 위함)
extension StringExtension on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}