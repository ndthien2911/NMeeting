class UserMeetingOutput {
  String id;
  String name;
  String phone;
  String avatar;
  int type;
  bool selected;
  bool disable;

  UserMeetingOutput(
      {required this.id,
      required this.name,
      required this.phone,
      required this.avatar,
      required this.type,
      required this.selected,
      required this.disable});

  factory UserMeetingOutput.fromJson(Map<String, dynamic> json) {
    return UserMeetingOutput(
        id: json['ID'],
        name: json['Name'],
        phone: json['Phone'],
        avatar: json['AvatarUrl'],
        type: json['Type'],
        selected: json['Selected'],
        disable: json['Disable']);
  }

  UserMeetingOutput.clone(UserMeetingOutput source)
      : this.id = source.id,
        this.name = source.name,
        this.phone = source.phone,
        this.avatar = source.avatar,
        this.type = source.type,
        this.selected = source.selected,
        this.disable = source.disable;

  Map toJson() => {
        'name': name,
        'id': id,
        'phone': phone,
        'avatar': avatar,
        'type': type,
        'selected': selected,
        'disable': disable
      };
}

class MemberVM {
  String? object;
  int? type;

  MemberVM({this.object, this.type});

  factory MemberVM.fromJson(Map<String, dynamic> json) {
    return MemberVM(object: json['Object'], type: json['Type']);
  }

  MemberVM.clone(MemberVM source)
      : this.object = source.object,
        this.type = source.type;

  Map toJson() => {
        'Object': object,
        'Type': type,
      };
}
