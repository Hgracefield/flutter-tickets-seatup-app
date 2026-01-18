class User {
  int? user_id;
  String user_email;
  String user_password;
  String user_name;
  String user_phone;
  String user_address;
  String user_signup_date;
  String user_account;
  String user_bank_name;
  String user_withdraw_date;

  User({
    this.user_id,
    required this.user_email,
    required this.user_password,
    required this.user_name,
    required this.user_phone,
    required this.user_address,
    required this.user_signup_date,
    required this.user_account,
    required this.user_bank_name,
    required this.user_withdraw_date,
  });

  factory User.fromJson(Map<String, dynamic> json)
  {
    return User(
      user_id: json['user_id'],
      user_email: json['user_email'], 
      user_password: json['user_password'], 
      user_name: json['user_name'], 
      user_phone: json['user_phone'], 
      user_address: json['user_address'], 
      user_signup_date: json['user_signup_date'], 
      user_account: json['user_account'], 
      user_bank_name: json['user_bank_name'], 
      user_withdraw_date: json['user_withdraw']);
  }

  Map<String, dynamic> toJson(){
    return{
      'user_id' : user_id,
      'user_email' : user_email,
      'user_password' : user_password,
      'user_name' : user_name,
      'user_phone' : user_phone,
      'user_address' : user_address,
      'user_signup_date' : user_signup_date,
      'user_account' : user_account,
      'user_bank_name' : user_bank_name,
      'user_withdraw' : user_withdraw_date,
    };
  }
}