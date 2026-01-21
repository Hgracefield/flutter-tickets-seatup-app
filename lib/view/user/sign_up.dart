import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/user.dart';
import 'package:seatup_app/util/global_data.dart';
import 'package:seatup_app/util/message.dart';
import 'package:seatup_app/vm/address_notifier.dart';
import 'package:seatup_app/vm/gps_notifier.dart';
import 'package:seatup_app/vm/user_notifier.dart';

class SignUp extends ConsumerStatefulWidget {
  final String email;
  final String name;
  final String phone;
  const SignUp({super.key, required this.email, required this.name, required this.phone});

  @override
  ConsumerState<SignUp> createState() => _SignUpState();
}

class _SignUpState extends ConsumerState<SignUp> {
  // === Property ===

  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController bankController;
  late TextEditingController accountController;

  late bool agreeTOS;
  late bool agreePP;
  late bool showPassword;
  late bool showConfirmPassword;
  late bool emailChecked;

  late double lat;
  late double lng;

  Message message = Message();

  final _formKey = GlobalKey<FormState>();
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$',
  );
  final phoneRegex = RegExp(r'^01[016789]-\d{3,4}-\d{4}$');
  final accountRegex = RegExp(r'^(\d{1,})(-(\d{1,})){1,}');

  String selectUrl = "${GlobalData.url}/customer/select";
  String insertUrl = "${GlobalData.url}/customer/insert";
  List<User> userList = [];

  bool isGoogleSignUp = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
    bankController = TextEditingController();
    accountController = TextEditingController();
    agreeTOS = false;
    agreePP = false;
    showPassword = true;
    showConfirmPassword = true;
    emailChecked = false;


    if(widget.email.isNotEmpty && widget.email.trim() != '')
    {
      isGoogleSignUp = true;
      emailController.text = widget.email;
      nameController.text = widget.name;
      phoneController.text = widget.phone;
      emailChecked = true;
      print('sdsdsss');
    }

    lat = 0.0;
    lng = 0.0;
    // 위치 데이터 요청은 1번만 가져온다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gpsNotifierProvider.notifier).checkLocationPermission();
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gps = ref.watch(gpsNotifierProvider);

    lat = gps.latitude;
    lng = gps.longitude;

    if (lat != 0.0) {
      getCurrentAddress();
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Seat Up',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '회원가입',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildLabel('이메일'),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            readOnly: isGoogleSignUp,
                            decoration: _buildInputDecoration(
                              'email@example.com',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return '이메일을 입력해주세요.';
                              if (!emailRegex.hasMatch(value)) return '올바른 이메일 형식이 아닙니다.';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        isGoogleSignUp 
                        ? SizedBox()
                        :
                        ElevatedButton(
                          onPressed: () => checkEmailDuplicate(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            minimumSize: const Size(100, 52),
                          ),
                          child: const Text(
                            '중복 확인',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  isGoogleSignUp
                  ?SizedBox()
                  :
                  Column(
                    children: [






                  _buildLabel('비밀번호'),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 20),
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: showPassword,
                      decoration: _buildInputDecoration('비밀번호를 입력해주세요')
                          .copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                showPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => showPassword = !showPassword),
                            ),
                          ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return '비밀번호를 입력해주세요.';
                        if (!passwordRegex.hasMatch(value)) return '8자 이상, 영문/숫자/특수문자 포함';
                        return null;
                      },
                    ),
                  ),
                  _buildLabel('비밀번호 확인'),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 20),
                    child: TextFormField(
                      controller: confirmPasswordController,
                      obscureText: showConfirmPassword,
                      decoration: _buildInputDecoration('비밀번호를 다시 입력해주세요')
                          .copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                showConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () =>
                                    showConfirmPassword = !showConfirmPassword,
                              ),
                            ),
                          ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return '비밀번호 확인을 입력해주세요.';
                        if (value != passwordController.text) return '비밀번호가 일치하지 않습니다.';
                        return null;
                      },
                    ),
                  ),
                    ],
                  ),
                  _buildLabel('이름'),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 20),
                    child: TextFormField(
                      controller: nameController,
                      decoration: _buildInputDecoration('본인 이름을 입력해주세요'),
                      validator: (value) {
                        if (value == null || value.isEmpty) return '이름을 입력해주세요.';
                        return null;
                      },
                    ),
                  ),
                  _buildLabel('전화번호'),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    child: TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _buildInputDecoration('010-1234-5678'),
                      validator: (value) {
                        if (value == null || value.isEmpty) return '전화번호를 입력해주세요.';
                        if (!phoneRegex.hasMatch(value)) return '올바른 전화번호 형식이 아닙니다.';
                        return null;
                      },
                    ),
                  ),
                  _buildLabel('주소'),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    child: TextFormField(
                      controller: addressController,
                      keyboardType: TextInputType.phone,
                      decoration: _buildInputDecoration('XX시'),
                      validator: (value) {
                        if (value == null || value.isEmpty) return '주소를 입력해주세요';
                        return null;
                      },
                    ),
                  ),
                  _buildLabel('은행'),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    child: TextFormField(
                      controller: bankController,
                      keyboardType: TextInputType.phone,
                      decoration: _buildInputDecoration('XX은행'),
                      validator: (value) {
                        if (value == null || value.isEmpty) return '은행명을 입력해주세요';
                        return null;
                      },
                    ),
                  ),
                  _buildLabel('계좌번호'),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    child: TextFormField(
                      controller: accountController,
                      keyboardType: TextInputType.phone,
                      decoration: _buildInputDecoration('0000-00-0000'),
                      validator: (value) {
                        if (value == null || value.isEmpty) return '계좌번호를 입력해주세요.';
                        if (!accountRegex.hasMatch(value)) return '올바른 계좌번호 형식이 아닙니다.';
                        return null;
                      },
                    ),
                  ),

                  _buildCheckboxRow(
                    agreeTOS,
                    (val) => setState(() => agreeTOS = val!),
                    '[필수] 서비스 이용약관 동의',
                  ),
                  _buildCheckboxRow(
                    agreePP,
                    (val) => setState(() => agreePP = val!),
                    '[필수] 개인정보 처리방침 동의',
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => checkSignup(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: const Text(
                      '가입하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '이미 계정이 있으신가요?',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          '로그인',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  } // build

  // === Widgets ===

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      filled: true,
      fillColor: const Color(0xFFF8F8F8),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
    );
  }

  Widget _buildCheckboxRow(
    bool value,
    Function(bool?) onChanged,
    String label,
  ) {
    return Row(
      children: [
        SizedBox(
          height: 32,
          width: 32,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF424242), fontSize: 14),
        ),
      ],
    );
  }

  // === Functions ===

  Future<void> checkSignup() async {
    final userNotifier = ref.read(userNotifierProvider.notifier);
    if (_formKey.currentState!.validate()) {
      if (emailChecked != true) {
        message.errorSnackBar(context, '이메일 중복 확인을 해주세요.');
      } else if (agreeTOS != true || agreePP != true) {
        message.errorSnackBar(context, '필수 약관에 동의해주세요.');
      } else {
        User user = User(
          user_id: 0,
          user_email: emailController.text.trim(),
          user_password: isGoogleSignUp? '' : passwordController.text.trim(),
          user_name: nameController.text.trim(),
          user_phone: phoneController.text.trim(),
          user_address: addressController.text.trim(),
          user_signup_date: "",
          user_account: accountController.text.trim(),
          user_bank_name: bankController.text.trim(),
          user_withdraw_date: "",
        );
        String result = await userNotifier.insertUser(user);
        // print("reuslt : $result");
        showResultPopup(result);
      }
    }
  }

  void showResultPopup(String result) {
    if (result == 'OK') {
      message.showAlertPopup(context, 'SeatUp의 회원이 되신 것을 환영합니다.', [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                emailController.clear();
                passwordController.clear();
                confirmPasswordController.clear();
                nameController.clear();
                phoneController.clear();
                addressController.clear();
                agreeTOS = false;
                agreePP = false;
                emailChecked = false;
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text('확인'),
            ),
          ],
        ),
      ]);
    } else {
      if (!mounted) return;
      message.errorSnackBar(context, '회원가입 중 서버 오류가 발생했습니다.');
    }
  }

  void checkEmailDuplicate() async {
    String email = emailController.text.trim();
    if (!emailRegex.hasMatch(email)) {
      return message.errorSnackBar(context, '올바른 이메일을 입력하세요.');
    }
    int count = await ref
        .read(userNotifierProvider.notifier)
        .existUser(emailController.text.trim());
    if (count == 0) {
      emailChecked = true;
      if (!mounted) return;
      message.successSnackBar(context, '$email\n사용 가능한 이메일입니다.');
    } else {
      emailChecked = false;
      if (!mounted) return;
      message.errorSnackBar(context, '$email\n이미 사용 중인 이메일입니다.');
    }
    setState(() {});
  }

  void getCurrentAddress() async {
    await ref
        .read(addressNotifier.notifier)
        .getAddressFromCoordinates(lat, lng);
    final address = ref.watch(addressNotifier).address;
    if (address!.isNotEmpty) {
      addressController.text = address;
    }
  }
}
