class LoginInput {
  final String username;
  final String password;
  final String device;
  final String tokenDevice;
  final String iMEICode;

  LoginInput(
      {required this.username,
      required this.password,
      required this.device,
      required this.tokenDevice,
      required this.iMEICode});

  Map toJson() => {
        'username': username,
        'password': password,
        'device': device,
        'tokenDevice': tokenDevice,
        'IMEICode': iMEICode
      };
}

class LoginOutput {
  final String accLogID;

  LoginOutput({required this.accLogID});
  Map toJson() => {'AccLogID': accLogID};
}

class OtpInput {
  final String id;
  final String phone;
  final String otpCode;

  OtpInput({required this.id, required this.phone, required this.otpCode});

  Map toJson() => {
        'id': id,
        'phone': phone,
        'otpCode': otpCode,
      };
}

class UserOutput {
  final String id;
  final String name;
  final int gender;
  final String phone;
  final String email;
  final String birthday;
  final String avatarUrl;
  final String signinAt;
  final String unitID;
  final String accLogID;

  UserOutput(
      {required this.id,
      required this.name,
      required this.gender,
      required this.phone,
      required this.email,
      required this.birthday,
      required this.avatarUrl,
      required this.signinAt,
      required this.unitID,
      required this.accLogID});
  Map toJson() => {
        'id': id,
        'name': name,
        'gender': gender,
        'phone': phone,
        'email': email,
        'birthday': birthday,
        'avatarUrl': avatarUrl,
        'signinAt': signinAt,
        'unitID': unitID,
        'accLogID': accLogID
      };
}

class ResetPassword {
  final String email;

  ResetPassword({required this.email});

  Map toJson() => {'Email': email};
}
