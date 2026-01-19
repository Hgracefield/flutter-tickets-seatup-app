enum LoginStatus {
  success(0), // 로그인 성공
  fail(1), // 로그인 실패
  withdraw(2); // 

  final int code;
  const LoginStatus(this.code);
}