class ProfileInput {
  final String name;
  final String birthday;
  final int? gender;
  final String email;
  final String? unitID;
  final String phone;

  ProfileInput(
      {required this.name,
      required this.birthday,
      this.gender,
      required this.email,
      this.unitID,
      required this.phone});

  Map toJson() => {
        'name': name,
        'birthday': birthday,
        'gender': gender,
        'email': email,
        'unitID': unitID,
        'phone': phone,
      };
}

class ProfileOutput {
  final String id;
  final String currentName;
  final int? gender;
  final String phone;
  final String email;
  final String birthDate;
  final String avatarUrl;
  final String signinAt;
  final String unitID;
  final String accLogID;

  ProfileOutput(
      {required this.id,
      required this.currentName,
      this.gender,
      required this.phone,
      required this.email,
      required this.birthDate,
      required this.avatarUrl,
      required this.signinAt,
      required this.unitID,
      required this.accLogID});
  Map toJson() => {
        'id': id,
        'currentName': currentName,
        'gender': gender,
        'phone': phone,
        'email': email,
        'birthDate': birthDate,
        'avatarUrl': avatarUrl,
        'signinAt': signinAt,
        'accLogID': accLogID
      };
}

class ProfileBasicOutput {
  final String userName;
  final String currentName;
  // final String fullName;
  final String avartaUrl;
  final String email;
  final String? gender;
  final String phone;
  final String birthDate;

  ProfileBasicOutput(
      {required this.userName,
      required this.currentName,
      required this.avartaUrl,
      required this.email,
      this.gender,
      required this.phone,
      required this.birthDate});
  Map toJson() => {
        'userName': userName,
        'currentName': currentName,
        'avartaUrl': avartaUrl,
        'email': email,
        'gender': gender,
        'phone': phone,
        'birthDate': birthDate
      };
}
